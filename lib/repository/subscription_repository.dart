import 'dart:developer';
import 'package:smart_menu/config/base_service.dart';
import 'package:smart_menu/models/subscription.dart';

class SubscriptionRepository {
  static const String url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Subscriptions?pageNumber=1&pageSize=10';

  final BaseService service = BaseService();

  Future<List<Subscription>> getAll() async {
    try {
      final response = await service.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> subcriptions = response.data;
        ;

        return subcriptions
            .map((subscription) => Subscription.fromJson(subscription))
            .toList();
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }
}
