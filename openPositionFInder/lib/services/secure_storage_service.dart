import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {//Using recommendations from chatgpt 2025
  static const _storage = FlutterSecureStorage();
  static const _apiKeyKey = 'together_ai_api_key';

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
}
