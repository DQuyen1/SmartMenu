import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store_menu.dart';
import 'package:smart_menu/models/product.dart';

class StoreMenuRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreMenus';

  final BaseService service = BaseService();

  Future<List<StoreMenu>> getAll(int storeId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 1000,
        'storeId': storeId,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> storeMenus = response.data;

        return storeMenus
            .map((storeMenu) => StoreMenu.fromJson(storeMenu))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createStoreMenu(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store menu: $e');
    }
  }

  Future<bool> updateStoreMenu(
      int storeMenuId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$storeMenuId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store menu: $e');
    }
  }

  Future<bool> deleteStoreMenu(int storeMenuId) async {
    try {
      final response =
          await service.delete('$url/$storeMenuId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store menu: $e');
    }
  }

  Future<List<Product>> getListProduct(int menuId) async {
    try {
      final response = await service.get(
          'http://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Products/menu-collection?menuId=$menuId',
          queryParameters: {
            'pageNumber': 1,
            'pageSize': 10,
            'menuId': menuId,
          });
      if (response.statusCode == 200) {
        final List<dynamic> products = response.data;
        return products.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching store menu: $e');
    }
  }
}
