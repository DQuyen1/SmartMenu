import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_menu/config/base_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PasswordResetHandler {
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Auth';

  BaseService service = BaseService();

  // Future<String> sendForgotPasswordRequest(String email) async {
  //   final encodedEmail = Uri.encodeComponent(email);
  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('$url/api/Auth/ForgotPassword?email=$encodedEmail'),
  //         )
  //         .timeout(Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       return 'Success';
  //     } else {
  //       print('Server responded with status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //       return 'Failed: Server responded with status ${response.statusCode}';
  //     }
  //   } catch (e) {
  //     throw new Exception("Message: $e");
  //   }
  // }

  Future<String> sendForgotPasswordRequest(String email) async {
    try {
      final response = await service
          .post('$url/ForgotPassword?email=$email')
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('Server responded with status code: ${response.statusCode}');
        return 'Failed: Server responded with status ${response.statusCode}';
      }
    } catch (e) {
      throw new Exception("Message: $e");
    }
  }
}
