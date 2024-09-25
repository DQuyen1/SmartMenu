import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/category.dart';

class CategoryRepository {
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Categories';

  final BaseService service = BaseService();

  Future<List<Category>> getAll(
    int brandId,
  ) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'brandId': brandId,
      });
      if (response.statusCode == 200) {
        final List<dynamic> categories = response.data;

        return categories
            .map((category) => Category.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}
