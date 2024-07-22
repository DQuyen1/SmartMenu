import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store_product.dart';

class StoreProductRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreProducts';

  final BaseService service = BaseService();

  Future<List<StoreProduct>> getAll(int storeId) async {
    try {
      final response =
          await service.get('$url/productsizeprices', queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
      });
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

  Future<bool> createStoreProduct(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post('$url/v2', data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store product: $e');
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
