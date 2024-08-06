import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/display.dart';

class DisplayRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays';

  final BaseService service = BaseService();

  Future<List<Display>> getAll() async {
    try {
      final response = await service.get('$url/DisplayItems', queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
      });
      log(response.toString());

      if (response.statusCode == 200) {
        final List<dynamic> displays = response.data;

        return displays.map((display) => Display.fromJson(display)).toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }

  Future<bool> createDisplay(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post('$url/v2', data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store collection: $e');
    }
  }

  Future<bool> updateDisplay(
      int displayId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$displayId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store collection: $e');
    }
  }

  Future<bool> deleteDisplay(int displayId) async {
    try {
      final response =
          await service.delete('$url/$displayId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store collection: $e');
    }
  }
}
