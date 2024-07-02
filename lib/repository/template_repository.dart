import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/template.dart'; // Replace with your template model

class TemplateRepository {
  static const url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Templates?pageNumber=1&pageSize=10';

  BaseService service = BaseService();

  Future<List<Template>> getAll() async {
    try {
      final response = await service.get(url);
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

  Future<bool> createTemplate(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating template: $e');
    }
  }

  // Future<bool> updateTemplate(Map<String, dynamic> requestBody) async {
  //   try {
  //     final response =
  //         await service.put(url, statusCodes: [200, 204], data: requestBody);

  //     if (response.statusCode == 204) return true;
  //     return false;
  //   } catch (e) {
  //     throw Exception('Error updating template: $e');
  //   }
  // }
}
