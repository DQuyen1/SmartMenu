import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/device_subscription.dart';
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

  Future<bool> updateLocation(
      StoreDevice storeDevice, String newLocation) async {
    try {
      final updateDate = {
        'storeDeviceName': storeDevice.storeDeviceName,
        'deviceLocation': newLocation,
        'deviceCode': storeDevice.deviceCode,
        'deviceWidth': storeDevice.deviceWidth,
        'deviceHeight': storeDevice.deviceHeight,
        // 'ratioType': storeDevice.ratioType,
        'isApproved': storeDevice.isApproved,
      };

      final response = await service.put('$url/${storeDevice.storeDeviceId}',
          data: updateDate, statusCodes: [200, 204], queryParameters: {});
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      ('Error updating location: $e');
      return false;
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

  Future<List<DeviceSubscription>> getDeviceSubscriptions(
      int storeDeviceId) async {
    try {
      final response =
          await service.get(deviceSubscriptionUrl, queryParameters: {
        'storeDeviceId': storeDeviceId,
        'pageNumber': 1,
        'pageSize': 10,
      });

      if (response.statusCode == 200) {
        final List<dynamic> deviceSubscriptions = response.data;

        return deviceSubscriptions
            .map((subscription) => DeviceSubscription.fromJson(subscription))
            .toList();
      } else {
        throw Exception(
            'Failed to load device subscriptions. Status code: ${response.statusCode}');
      }
    } catch (error) {
      log('Error fetching device subscriptions: $error');
      throw Exception('Error fetching device subscriptions: $error');
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

  Future<bool> checkSubscription(int storeDeviceId) async {
    try {
      final response =
          await service.get('$url/isSubscription?storeDeviceId=$storeDeviceId');

      if (response.statusCode == 200) return response.data as bool;
      return false;
    } catch (e) {
      throw Exception('Error checking subscription');
    }
  }

  Future<List<StoreDevice>> getSubscribedDevices(int storeId) async {
    try {
      final response = await service.get(url, queryParameters: {
        'pageNumber': 1,
        'pageSize': 10,
        'storeId': storeId,
      });
      if (response.statusCode == 200) {
        final List<dynamic> storeDevices = response.data;

        List<StoreDevice> devices = storeDevices
            .map((storeDevice) => StoreDevice.fromJson(storeDevice))
            .toList();

        List<StoreDevice> subscribedDevices = [];
        for (var device in devices) {
          bool isSubscribed = await checkSubscription(device.storeDeviceId);
          if (isSubscribed) {
            subscribedDevices.add(device);
          }
        }

        return subscribedDevices;
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching subscribed devices: $error');
    }
  }
}
