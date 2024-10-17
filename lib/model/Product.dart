class Product {
  int id;
  String name;
  double price;
  double sale_price;
  String desciption;
  String author;
  String image;
  String category_id;

  Product(this.id, this.name, this.price, this.sale_price, this.desciption,
      this.author, this.image, this.category_id);

  factory Product.fromJson(Map<String, Object?> data) {
    return Product(
        int.parse(data['id'].toString()),
        data['name'].toString(),
        double.parse(data['price'].toString()),
        double.parse(data['sale_price'].toString()),
        data['desciption'].toString(),
        data['author'].toString(),
        data['image'].toString(),
        data['category_id'].toString()
    );
  }

  Map<String, String> toMap() {
    return {
      "id": id.toString(),
      "name": name,
      "price": price.toString(),
      "sale_price": sale_price.toString(),
      "desciption": desciption,
      "author": author,
      "image": image,
      "category_id": category_id.toString()
    };
  }
}
