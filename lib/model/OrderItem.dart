class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class Order {
  final int userId;
  final String shippingAddress;
  final List<OrderItem> items;
  final double totalPrice;

  Order({
    required this.userId,
    required this.shippingAddress,
    required this.items,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shippingAddress': shippingAddress,
      'items': items.isNotEmpty ? items.map((item) => item.toJson()).toList() : [],
      'totalPrice': totalPrice,
    };
  }
}
