import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/user.dart';

class UserRepository {
  static const url = 'https://6517671f582f58d62d34f3b3.mockapi.io/api/v1/users';

  BaseService service = BaseService();

  Future<List<User>> getAll() async {
    try {
      final response = await service.get(url);
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> users = response.data;

        return users.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createUser() async {
    final reqBody = {};

    try {
      final response = await service.post(url, data: reqBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<bool> updateUser() async {
    try {
      final response =
          await service.put(url, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<bool> deleteUser() async {
    try {
      final response = await service.delete(url, statusCodes: [204, 200]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }
}
