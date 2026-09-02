import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.104:8000'; // Or use 10.0.2.2 if on Android emulator

  static Future<Map<String, dynamic>> register(String name, String email, String mobile, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['detail'] ?? 'Failed to register');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['detail'] ?? 'Failed to login');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['detail'] ?? 'Failed to verify OTP');
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['detail'] ?? 'Failed to resend OTP');
    }
  }
}

