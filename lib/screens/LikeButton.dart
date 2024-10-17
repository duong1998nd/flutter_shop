import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LikeButton extends StatefulWidget {
  final int productId;

  LikeButton({required this.productId});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final response = await http.get(
      Uri.parse('https://your-api.com/api/likes/areLiked?userId=1&productIds=${widget.productId}'),
    );
    if (response.statusCode == 200) {
      final isLikedByUser = json.decode(response.body);
      setState(() {
        isLiked = isLikedByUser[0]; // Assuming the API returns a list of booleans
      });
    }
  }

  // Handle like/unlike actions
  Future<void> _toggleLike() async {
    String apiUrl = isLiked
        ? 'https://your-api.com/api/likes/remove?productId=${widget.productId}'
        : 'https://your-api.com/api/likes/add?productId=${widget.productId}';

    final response = await http.post(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleLike,
    );
  }
}
