import 'UserDTO.dart';

class OrderItemDTO {
  final int id;
  final String productName;
  final int quantity;
  final double price;

  OrderItemDTO({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemDTO.fromJson(Map<String, dynamic> json) {
    return OrderItemDTO(
      id: json['id'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class OrderDTO {
  final int id;
  final String shippingAddress;
  final double totalPrice;
  final String orderStatus;
  final List<OrderItemDTO> items;
  final UserDTO? user;

  OrderDTO({
    required this.id,
    required this.shippingAddress,
    required this.totalPrice,
    required this.orderStatus,
    required this.items,
    required this.user,
  });

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List;
    List<OrderItemDTO> orderItems = itemsJson.map((i) => OrderItemDTO.fromJson(i)).toList();

    return OrderDTO(
      id: json['id'],
      shippingAddress: json['shippingAddress'],
      totalPrice: json['totalPrice'],
      orderStatus: json['orderStatus'],
      items: orderItems,
      user: UserDTO.fromJson(json['user'] ?? {}),
    );
  }
}
