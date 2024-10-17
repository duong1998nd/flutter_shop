// product_dto.dart

class ProductDTO {
  final int id;
  final String name;
  final double price;
  final String image;

  // Constructor
  ProductDTO({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  // Factory method to create a ProductDTO from JSON
  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    return ProductDTO(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(), // Ensure the price is converted to double
      image: json['image'],
    );
  }

  // Method to convert ProductDTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
    };
  }
}
