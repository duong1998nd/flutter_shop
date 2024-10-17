class Cart {
  int id;
  int user_id;
  int cart_item_id;

  Cart(this.id, this.user_id, this.cart_item_id);

  factory Cart.fromJson(Map<String, Object?> data) {
    return Cart(
      _parseInt(data['id']),
      _parseInt(data['user_id']),
      _parseInt(data['cart_item_id']),
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
      "user_id": user_id.toString(),
      "cart_item_id": cart_item_id.toString(),
    };
  }
}