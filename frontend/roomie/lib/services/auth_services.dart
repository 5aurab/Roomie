import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.x.x:8000/api/users';
  // Replace x.x with your laptop ip
  static const _storage = FlutterSecureStorage();

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';


  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  static Future<String?> signup({
    required String fullName,
    required String displayName,
    required String email,
    required String password,
    required DateTime dob,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'display_name': displayName,
        'email': email,
        'password': password,
        'date_of_birth':
            '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}',
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
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) return 'failed to get firebase token';

      final response = await http.post(
        Uri.parse('$_baseUrl/google/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebase_token': firebaseToken}),
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
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'google sign-in failed';
    } catch (_) {
      return 'something went wrong, please try again';
    }
  }


  static Future<void> logout() async {
    await clearTokens();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
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