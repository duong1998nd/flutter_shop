class Order {
  final int id;
  final String user;
  final String shippingAddress;
  final double totalPrice;
  String status;

  Order({
    required this.id,
    required this.user,
    required this.shippingAddress,
    required this.totalPrice,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user: json['user']['username'],
      shippingAddress: json['shippingAddress'],
      totalPrice: json['totalPrice'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'shippingAddress': shippingAddress,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
