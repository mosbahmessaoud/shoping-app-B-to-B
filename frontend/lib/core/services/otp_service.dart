// lib/services/otp_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OTPService {
  static const String baseUrl = 'https://adventurous-charm-production.up.railway.app';
  
  // Send OTP for registration
  Future<Map<String, dynamic>> sendRegistrationOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_type': 'registration',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }
  
  // Send OTP for password reset
  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_type': 'password_reset',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }
  
  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otpCode,
    required String otpType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
        'otp_type': otpType,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }
  
  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
        'new_password': newPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }
  
  // Register client (after OTP verification)
  Future<Map<String, dynamic>> registerClient({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    String? address,
    String? city,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/client/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'address': address,
        'city': city,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }
}