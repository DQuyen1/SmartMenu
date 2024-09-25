import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/collection.dart';

class CollectionRepository {
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Collections';

  final BaseService service = BaseService();

  Future<List<Collection>> getAll(int brandId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'brandId': brandId,
      });

      if (response.statusCode == 200) {
        final List<dynamic> collections = response.data;

        return collections
            .map((collection) => Collection.fromJson(collection))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}
