class Like {
  final int id;
  final int userId;
  final int productId;
  final DateTime likedAt;

  Like({required this.id, required this.userId, required this.productId, required this.likedAt});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      likedAt: DateTime.parse(json['likedAt']),
    );
  }
}
