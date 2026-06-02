import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:8000/api/users';
  // Replace x.x with your laptop IP
  static const _storage = FlutterSecureStorage();

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';


  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  static Future<String?> _getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> signup({
    required String displayName,
    required String email,
    required String password,
    required DateTime dob,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'display_name': displayName,
        'email': email,
        'password': password,
        'confirm_password': password,
        'dob': '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await saveTokens(
        data['tokens']['access'],
        data['tokens']['refresh'],
      );
      return null;
    }

    return _extractError(data);
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveTokens(
        data['tokens']['access'],
        data['tokens']['refresh'],
      );
      return null;
    }

    return _extractError(data);
  }

  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'sign-in cancelled';

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      if (accessToken == null) return 'failed to get Google access token';

      final response = await http.post(
        Uri.parse('$_baseUrl/google/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': accessToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveTokens(
          data['tokens']['access'],
          data['tokens']['refresh'],
        );
        return null;
      }

      return _extractError(data);
    } catch (e) {
      return 'something went wrong, please try again';
    }
  }
  static Future<void> logout() async {
    final refresh = await _getRefreshToken();
    final headers = await _authHeaders();

    if (refresh != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout/'),
          headers: headers,
          body: jsonEncode({'refresh': refresh}),
        );
      } catch (_) {
      }
    }

    await clearTokens();
    await GoogleSignIn().signOut();
  }

  static Future<String?> requestOtp({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/otp/request/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/otp/verify/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveTokens(
        data['tokens']['access'],
        data['tokens']['refresh'],
      );
      return null;
    }

    return _extractError(data);
  }

  static Future<String?> sendEmailVerification() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/email/send-verification/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static Future<String?> verifyEmail({required String otp}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/email/verify/'),
      headers: await _authHeaders(),
      body: jsonEncode({'otp': otp}),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static Future<String?> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<String?> updateProfile(Map<String, dynamic> fields) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profile/'),
      headers: await _authHeaders(),
      body: jsonEncode(fields),
    );

    if (response.statusCode == 200) return null;
    return _extractError(jsonDecode(response.body));
  }

  static String _extractError(dynamic data) {
    if (data is Map) {
      if (data.containsKey('error')) return data['error'];
      final firstKey = data.keys.first;
      final firstValue = data[firstKey];
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
      return firstValue.toString();
    }
    return 'something went wrong';
  }
}