class CartItem {
  int id;
  int cart;
  int product;
  int quantity;

  CartItem(this.id, this.cart, this.product, this.quantity);

  factory CartItem.fromJson(Map<String, Object?> data) {
    return CartItem(
      _parseInt(data['id']),
      _parseInt(data['cart']),
      _parseInt(data['product']),
      _parseInt(data['quantity'])
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 0; // Default value or handle the error
    }

    // Try parsing the number, handle exceptions
    try {
      return int.parse(value.toString());
    } catch (e) {
      print('Error parsing int: $value');
      return 0; // Default value in case of error
    }
  }

  Map<String, String> toMap() {
    return {
      "id": id.toString(),
      "cart": cart.toString(),
      "product": product.toString(),
      "quantity": quantity.toString(),
    };
  }
}