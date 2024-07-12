import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/template.dart';

class TemplateRepository {
  final String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Templates';

  BaseService service = BaseService();

  Future<List<Template>> getAll(int brandId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'brandId': brandId,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> templates = response.data;

        return templates
            .map((template) => Template.fromJson(template))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> updateTemplate(
      String templateId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put(
        '$url/$templateId',
        data: requestBody,
        queryParameters: null,
        statusCodes: [],
      );

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating template: $e');
    }
  }
}
