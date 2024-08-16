class Subscription {
  final int subscriptionId;
  final String name;
  final String description;
  final double price;
  final int dayDuration;
  final bool isActive;
  final bool isDeleted;

  Subscription({
    required this.subscriptionId,
    required this.name,
    required this.description,
    required this.price,
    required this.dayDuration,
    required this.isActive,
    required this.isDeleted,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['subscriptionId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      dayDuration: json['dayDuration'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'name': name,
      'description': description,
      'price': price,
      'dayDuration': dayDuration,
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }
}
