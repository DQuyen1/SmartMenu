import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store_product.dart';

class StoreProductRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreProducts';

  final BaseService service = BaseService();

  Future<List<StoreProduct>> getAll(int storeId, {String? searchString}) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'pageNumber': 1,
        'pageSize': 1000,
        'storeId': storeId,
      };
      if (searchString != null && searchString.isNotEmpty) {
        queryParameters['searchString'] = searchString;
      }

      final response = await service.get('$url/productsizeprices',
          queryParameters: queryParameters);
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> storeProducts = response.data;

        return storeProducts
            .map((storeProduct) => StoreProduct.fromJson(storeProduct))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<Map<String, dynamic>> createStoreProduct(
      Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post('$url/v2', data: requestBody);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Store products added successfully'
        };
      } else if (response.statusCode == 400) {
        // Always return a user-friendly message for 400 status
        return {
          'success': false,
          'message': 'This list of products already exists'
        };
      }
      return {'success': false, 'message': 'Failed to add store products'};
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        return {
          'success': false,
          'message': 'This list of products already exists'
        };
      }
      return {
        'success': false,
        'message': 'Error creating store product. Please try again.'
      };
    }
  }

  Future<bool> updateStoreProduct(int storeProductId, bool isAvailable) async {
    try {
      final response = await service.put(
        '$url/$storeProductId',
        data: {'isAvailable': isAvailable},
        statusCodes: [200, 204],
        queryParameters: {},
      );

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store product: $e');
    }
  }

  Future<bool> deleteStoreProduct(int storeProductId) async {
    try {
      final response =
          await service.delete('$url/$storeProductId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store product: $e');
    }
  }
}
