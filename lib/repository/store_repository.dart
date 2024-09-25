import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store.dart';

class StoreRepository {
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Stores';

  BaseService service = BaseService();

  Future<List<Store>> getStoreyById(int storeId) async {
    try {
      final response = await service
          .get(url, queryParameters: {'pageNumber': 1, 'pageSize': 10});
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> stores = response.data;

        return stores.map((store) => Store.fromJson(store)).toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}
