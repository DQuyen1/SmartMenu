import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store_collection.dart';

class StoreCollectionRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreCollections';

  final BaseService service = BaseService();

  Future<List<StoreCollection>> getAll(int storeId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> storeCollections = response.data;

        return storeCollections
            .map((storeCollection) => StoreCollection.fromJson(storeCollection))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createStoreCollection(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store collection: $e');
    }
  }

  Future<bool> updateStoreCollection(
      int storeCollectionId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$storeCollectionId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store collection: $e');
    }
  }

  Future<bool> deleteStoreCollection(int storeCollectionId) async {
    try {
      final response = await service
          .delete('$url/$storeCollectionId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store collection: $e');
    }
  }
}
