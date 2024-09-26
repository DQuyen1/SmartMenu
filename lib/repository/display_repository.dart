import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/display.dart';

class DisplayRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays';

  final BaseService service = BaseService();

  Future<List<Display>> getAll(int storeId) async {
    try {
      final response =
          await service.get('$url/DisplayItems/v2', queryParameters: {
        'pageNumber': 1,
        'pageSize': 100,
        'storeId': storeId,
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
      throw Exception('Error fetching display: $error');
    }
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }

  Future<Map<String, dynamic>> createDisplay(
      Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post('$url/v2', data: requestBody);
      return {'success': true};
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          final errorMessage =
              e.response!.data['error'] ?? 'An unknown error occurred';
          return {'success': false, 'error': errorMessage};
        }
      }
      return {
        'success': false,
        'error': e.message ?? 'An unexpected error occurred'
      };
    } catch (e) {
      return {'success': false, 'error': 'Error creating display: $e'};
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

  Future<bool> updateActiveHour(Display display, double newActiveHour) async {
    try {
      final updateData = {
        'menuId': display.menuId,
        'collectionId': display.collectionId,
        'templateId': display.templateId,
        'activeHour': newActiveHour,
        'storeDeviceId': display.storeDeviceId,
      };

      final response = await service.put(
        '$url/${display.displayId}',
        data: updateData,
        statusCodes: [200, 204],
        queryParameters: {},
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error updating active hour: $e');
      return false;
    }
  }

  Future<bool> deleteDisplay(int displayId) async {
    try {
      final response =
          await service.delete('$url/$displayId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting display: $e');
    }
  }

  Future<String> getMenuName(int menuId) async {
    final BaseService service = BaseService();
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Menus?menuId=$menuId&pageNumber=1&pageSize=10';

    try {
      final response = await service.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final List<dynamic> menus = response.data;

        if (menus.isNotEmpty && menus[0] is Map<String, dynamic>) {
          final menu = menus[0] as Map<String, dynamic>;
          return menu['menuName'] ?? 'Not found';
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        return 'Not found';
      }
    } catch (e) {
      throw Exception('Error fetching menu name: $e');
    }
  }

  Future<String> getCollectionName(int collectionId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Collections?collectionId=$collectionId&pageNumber=1&pageSize=10';

    try {
      final response = await service.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final List<dynamic> collections = response.data;

        if (collections.isNotEmpty && collections[0] is Map<String, dynamic>) {
          final collection = collections[0] as Map<String, dynamic>;
          return collection['collectionName'] ?? 'Not found';
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        return 'Not found';
      }
    } catch (e) {
      throw Exception('Error fetching collection name: $e');
    }
  }

  Future<String> getDeviceName(int storeDeviceId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices?storeDeviceId=$storeDeviceId&pageNumber=1&pageSize=10';

    try {
      final response = await service.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final List<dynamic> devices = response.data;

        if (devices.isNotEmpty && devices[0] is Map<String, dynamic>) {
          final device = devices[0] as Map<String, dynamic>;
          return device['storeDeviceName'] ?? 'Not found';
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        return 'Not found';
      }
    } catch (e) {
      throw Exception('Error fetching device name: $e');
    }
  }

  Future<String> getTemplateName(int templateId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Templates?templateId=$templateId&pageNumber=1&pageSize=10';

    try {
      final response = await service.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final List<dynamic> templates = response.data;

        if (templates.isNotEmpty && templates[0] is Map<String, dynamic>) {
          final template = templates[0] as Map<String, dynamic>;
          return template['templateName'] ?? 'Not found';
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        return 'Not found';
      }
    } catch (e) {
      throw Exception('Error fetching template name: $e');
    }
  }

  Future<bool> updateDisplayProductGroup(
      int displayItemId, Map<String, dynamic> requestBody) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/DisplayItems';
    try {
      final response = await service.put('$url/$displayItemId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating product group: $e');
    }
  }

  Future<Map<String, dynamic>> getDisplayDetails(int displayId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/DisplayItems?displayId=$displayId&pageNumber=1&pageSize=10';
    try {
      final response = await service.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> displays = response.data;

        if (displays.isNotEmpty) {
          final List<int> displayItemIds = displays
              .map<int>((item) => item['displayItemId'] as int)
              .toList();

          final List<int> productGroupIds = displays
              .map<int>((item) => item['productGroupId'] as int)
              .toList();

          return {
            'displayItemIds': displayItemIds,
            'productGroupIds': productGroupIds,
          };
        } else {
          throw Exception('No valid data found');
        }
      } else {
        throw Exception('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching display details: $e');
      rethrow;
    }
  }

  Future<String> getProductGroupName(int productGroupId) async {
    final url =
        'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/ProductGroup?productGroupId=$productGroupId&pageNumber=1&pageSize=10';

    try {
      final response = await service.get(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final List<dynamic> productGroups = response.data;

        if (productGroups.isNotEmpty &&
            productGroups[0] is Map<String, dynamic>) {
          final productGroup = productGroups[0] as Map<String, dynamic>;
          return productGroup['productGroupName'] ?? 'Not found';
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        return 'Not found';
      }
    } catch (e) {
      throw Exception('Error fetching product group name: $e');
    }
  }
}
