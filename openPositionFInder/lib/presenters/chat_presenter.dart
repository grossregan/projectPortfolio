import 'package:cs_3541_final_project/models/chatbot_model.dart';

class ChatPresenter {
  final ChatbotModel _model;

  ChatPresenter({required ChatbotModel model}) : _model = model;

  List<Map<String, String>> get messageHistory => _model.messageHistory;

  Future<String> sendMessage(String message) async {
    return await _model.sendMessage(message);
  }

  void clearHistory() {
    _model.clearHistory();
  }

  Future<void> setApiKey(String apiKey) async {
    await _model.secureStorage.saveApiKey(apiKey);
  }

  Future<void> clearApiKey() async {
    await _model.secureStorage.deleteApiKey();
  }

  Future<String?> getApiKey() async {
    return await _model.secureStorage.getApiKey();
  }
}
