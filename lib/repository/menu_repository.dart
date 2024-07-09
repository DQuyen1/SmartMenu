import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/menu.dart';

class MenuRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Menus';

  final BaseService service = BaseService();

  Future<List<Menu>> getAll() async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> menus = response.data;

        return menus.map((menu) => Menu.fromJson(menu)).toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createMenu(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating menu: $e');
    }
  }

  Future<bool> updateMenu(int menuId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$menuId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating menu: $e');
    }
  }

  Future<bool> deleteMenu(int menuId) async {
    try {
      final response =
          await service.delete('$url/$menuId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting menu: $e');
    }
  }
}
