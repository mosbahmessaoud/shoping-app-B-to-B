import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<bool> isLoggedIn() async => await _storage.getToken() != null;
  
  Future<String?> getUserType() => _storage.getUserType();

  /// Unified login method that automatically detects user type
  Future<Map<String, dynamic>> login(String email, String password) async {
    // First, check the user type
    final typeResponse = await _api.getTypeOfUser({'email': email, 'password': password});
    final userType = typeResponse.data as String;

    // Login based on user type
    if (userType == 'admin') {
      return await loginAdmin(email, password);
    } else if (userType == 'client') {
      return await loginClient(email, password);
    } else {
      throw Exception('Type d\'utilisateur inconnu: $userType');
    }
  }

  Future<Map<String, dynamic>> loginClient(String email, String password) async {
    final response = await _api.loginClient({'email': email, 'password': password});
    await _storage.saveToken(response.data['access_token']);
    await _storage.saveUserType('client');
    await _storage.saveUserData(response.data['client']);
    return response.data;
  }

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    final response = await _api.loginAdmin({'email': email, 'password': password});
    await _storage.saveToken(response.data['access_token']);
    await _storage.saveUserType('admin');
    await _storage.saveUserData(response.data['admin']);
    return response.data;
  }

  Future<Map<String, dynamic>> registerClient(Map<String, dynamic> data) async {
    final response = await _api.registerClient(data);
    return response.data;
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<Map<String, dynamic>?> getCurrentUser() => _storage.getUserData();
}