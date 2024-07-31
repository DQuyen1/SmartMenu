import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_menu/models/collection.dart';

class CollectionRepository {
  final String apiUrl =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Collections';

  Future<List<Collection>> getAll(int brandId,
      {int pageNumber = 1, int pageSize = 10}) async {
    final url = Uri.parse(
        '$apiUrl?brandId=$brandId&pageNumber=$pageNumber&pageSize=$pageSize');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Collection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load collections');
    }
  }
}
