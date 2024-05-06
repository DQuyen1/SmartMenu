import 'dart:developer';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = Dio();

  Future<void> login(username, password) async {
    const url = 'asdsdadsads';
    var reqBody = {"username": username, "password": password};

    try {
      final response = await _dio.post(url, data: reqBody);
      log(response.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> logout() async {
    log('adssad');
  }
}
