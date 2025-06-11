import 'dart:convert';

import 'package:cs_3541_final_project/config/api_config.dart';
import 'package:cs_3541_final_project/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ChatbotModel {
  static const String _baseUrl = 'https://api.together.xyz/v1/chat/completions';
  final SecureStorageService secureStorage = SecureStorageService();
  String? _apiKey;
  List<Map<String, String>> _messageHistory = [];
  http.Client? _client;
  bool _isInitialized = false;
  bool _isProcessingMessage = false;

  ChatbotModel() {
    _initializeSecurely();
    _resetClient();
  }

  void _resetClient() {//Using recommendations from chatgpt 2025
    _client?.close();
    _client = http.Client();
  }

  Future<void> _initializeSecurely() async {
    if (_isInitialized) return;

    try {
      _apiKey = await ApiConfig.getApiKey();
      if (_apiKey == null) {
        throw Exception('API key not found in secure storage');
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing API key: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  void dispose() {
    _client?.close();
    _client = null;
  }

  Future<void> _loadApiKey() async {
    if (!_isInitialized) {
      await _initializeSecurely();
    }

    if (_apiKey == null || _apiKey!.trim().isEmpty) {
      throw Exception('API key not found in secure storage');
    }
  }

  bool get isApiKeySet => _apiKey != null;

  List<Map<String, String>> get messageHistory =>
      List.unmodifiable(_messageHistory);//Using recommendations from chatgpt 2025

  void _validateMessage(String message) {
    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }


    if (_messageHistory.isNotEmpty) {
      final lastMessage = _messageHistory.last;
      if (lastMessage['role'] == 'assistant' &&
              message.contains('assistant:') ||
          message.contains('user:')) {
        throw Exception('Invalid message format detected');//Using recommendations from chatgpt 2025
      }
    }
  }

  void _addMessageToHistory(String role, String content) {
    _validateMessage(content);
    _messageHistory.add({
      'role': role,
      'content': content.trim(),
    });
  }

  String _parseAssistantMessage(Map<String, dynamic> data) {//Using recommendations from chatgpt 2025
    String? assistantMessage;

    // Try different response formats with validation
    try {
      if (data.containsKey('choices') &&
          data['choices'] is List &&
          data['choices'].isNotEmpty) {
        final choice = data['choices'][0];
        if (choice.containsKey('message') &&
            choice['message'] is Map &&
            choice['message'].containsKey('content')) {
          assistantMessage = choice['message']['content'];
        } else if (choice.containsKey('text')) {
          assistantMessage = choice['text'];
        }
      } else if (data.containsKey('output') &&
          data['output'].containsKey('choices') &&
          data['output']['choices'] is List &&
          data['output']['choices'].isNotEmpty) {
        assistantMessage = data['output']['choices'][0]['text'];
      }

      if (assistantMessage == null || assistantMessage.trim().isEmpty) {
        print('Response data: $data');
        throw Exception('Invalid or empty response from API');
      }

      // Validate the message format
      if (assistantMessage.contains('user:') ||
          assistantMessage.contains('assistant:')) {
        throw Exception('Invalid response format detected');
      }

      return assistantMessage.trim();
    } catch (e) {
      print('Error parsing assistant message: $e');
      print('Response data: $data');
      throw Exception('Failed to parse assistant response');
    }
  }

  Future<String> sendMessage(String message) async {
    if (_isProcessingMessage) {
      throw Exception('Another message is still being processed');
    }

    try {
      _isProcessingMessage = true;

      if (_apiKey == null) {
        await _loadApiKey();
        if (_apiKey == null) {
          throw Exception('API key not set');
        }
      }

      _validateMessage(message);
      _addMessageToHistory('user', message);


      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          if (attempt > 1) {
            // Reset client on retry attempts
            _resetClient();
            print('Resetting connection for attempt $attempt');//Using recommendations from chatgpt 2025
          }

          final requestBody = {
            'model': 'mistralai/Mixtral-8x7B-Instruct-v0.1',
            'messages': _messageHistory,
            'temperature': 0.7,
            'max_tokens': 1024,
          };

          if (_client == null) {
            _resetClient();
          }

          final response = await _client!
              .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
              .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('Request timed out on attempt $attempt');
              throw Exception('Request timed out');
            },
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final assistantMessage = _parseAssistantMessage(data);
            _addMessageToHistory('assistant', assistantMessage);
            return assistantMessage;
          } else if (response.statusCode == 401) {
            _apiKey = null;
            _isInitialized = false;
            throw Exception('Invalid API key. Please check the configuration.');
          } else {
            print('Response body: ${response.body}');
            throw Exception('Failed to get response: ${response.statusCode}');
          }
        } catch (e) {
          print('Error in sendMessage (attempt $attempt/3): $e');

          if (attempt == 3) {
            if (e is http.ClientException) {
              throw Exception(
                  'Network error: Unable to connect to the server after 3 attempts');
            }
            rethrow;
          }

          // Wait before retrying, with increasing delay
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      throw Exception('Failed to send message after all attempts');
    } finally {
      _isProcessingMessage = false;
    }
  }

  void clearHistory() {
    _messageHistory.clear();
  }
}
