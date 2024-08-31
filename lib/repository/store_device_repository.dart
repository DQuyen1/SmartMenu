import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/store_device.dart';

class StoreDeviceRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/StoreDevices';

  final BaseService service = BaseService();

  Future<List<StoreDevice>> getAll(int storeId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
      });
      if (response.statusCode == 200) {
        final List<dynamic> storeDevices = response.data;

        return storeDevices
            .map((storeDevice) => StoreDevice.fromJson(storeDevice))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> createStoreDevice(Map<String, dynamic> requestBody) async {
    try {
      final response = await service.post(url, data: requestBody);

      if (response.statusCode == 201) return true;
      return false;
    } catch (e) {
      throw Exception('Error creating store device: $e');
    }
  }

  Future<bool> updateStoreDevice(
      int storeDeviceId, Map<String, dynamic> requestBody) async {
    try {
      final response = await service.put('$url/$storeDeviceId',
          data: requestBody, statusCodes: [200, 204], queryParameters: {});

      if (response.statusCode == 204 || response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store device: $e');
    }
  }

  Future<bool> deleteStoreDevice(int storeDeviceId) async {
    try {
      final response =
          await service.delete('$url/$storeDeviceId', statusCodes: [200, 204]);

      if (response.statusCode == 204) return true;
      return false;
    } catch (e) {
      throw Exception('Error deleting store device: $e');
    }
  }

  Future<bool> deviceExists(int storeId, String name) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
        'searchString': name,
      });
      if (response.statusCode == 200) {
        final List<dynamic> storeDevices = response.data;
        return storeDevices.isNotEmpty;
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  Future<bool> acceptDevice(int storeDeviceId) async {
    try {
      final response = await service.put('$url/$storeDeviceId/status',
          statusCodes: [200], queryParameters: {});
      if (response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store product: $e');
    }
  }

  Future<bool> changeRatioType(int storeDeviceId) async {
    try {
      final response = await service.put('$url/$storeDeviceId/ratio-type',
          statusCodes: [200], queryParameters: {});
      if (response.statusCode == 200) return true;
      return false;
    } catch (e) {
      throw Exception('Error updating store product: $e');
    }
  }

  static const String deviceSubscriptionUrl =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/DeviceSubscriptions';

  Future<int> saveSubscription({
    required int storeDeviceId,
    required int subscriptionId,
  }) async {
    try {
      final requestBody = {
        "storeDeviceId": storeDeviceId,
        "subscriptionId": subscriptionId,
      };

      final response =
          await service.post(deviceSubscriptionUrl, data: requestBody);

      if (response.statusCode == 201) {
        final responseData = response.data;

        final deviceSubscriptionId = responseData['deviceSubscriptionId'];

        log('Subscription saved successfully for device $storeDeviceId.');

        return deviceSubscriptionId;
      } else {
        log('Failed to save subscription. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      log('Error saving subscription: $e');
      return 0;
    }
  }

  static const String transactionUrl =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Transactions';

  Future<bool> saveTransaction(
      {required int deviceSubscriptionId,
      required double amount,
      required int payType}) async {
    try {
      final requestBody = {
        "deviceSubscriptionId": deviceSubscriptionId,
        "amount": amount,
        "payType": payType,
      };
      final response = await service.post(transactionUrl, data: requestBody);

      if (response.statusCode == 201) {
        log('Transaction saved successfully.');
        return true;
      } else {
        log('Failed to save subscription. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error saving transaction: $e');
      return false;
    }
  }
}
