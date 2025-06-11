import 'package:cs_3541_final_project/services/secure_storage_service.dart';

class ApiConfig {
  static final _storage = SecureStorageService();//Using recommendations from chatgpt 2025

  static Future<String?> getApiKey() async {
    return await _storage.getApiKey();
  }
}
