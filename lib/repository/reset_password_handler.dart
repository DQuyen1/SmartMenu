import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PasswordResetHandler {
  final storage = FlutterSecureStorage();
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com';

  Future<void> initUniLinks(BuildContext context) async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        handleDeepLink(initialLink, context);
      }
    } catch (e) {
      print('Error initializing deep links: $e');
    }

    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri.toString(), context);
      }
    }, onError: (err) {
      print('Error in deep link stream: $err');
    });
  }

  void handleDeepLink(String link, BuildContext context) {
    final uri = Uri.parse(link);
    if (uri.path == '/reset-password') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      if (token != null && email != null) {
        storage.write(key: 'reset_token', value: token);
        storage.write(key: 'reset_email', value: email);
        Navigator.pushNamed(context, '/reset_password');
      }
    }
  }

  Future<String> sendForgotPasswordRequest(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    try {
      final response = await http
          .post(
            Uri.parse('$url/api/Auth/ForgotPassword?email=$encodedEmail'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('Server responded with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return 'Failed: Server responded with status ${response.statusCode}';
      }
    } catch (e) {
      throw new Exception("Message: $e");
    }
  }

  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    final token = await storage.read(key: 'reset_token');
    final email = await storage.read(key: 'reset_email');

    if (token == null || email == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$url/api/Auth/ResetPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password': newPassword,
        'confirmPassword': confirmPassword,
        'email': email,
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'reset_token');
      await storage.delete(key: 'reset_email');
      return true;
    }
    return false;
  }
}
