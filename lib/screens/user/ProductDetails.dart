import 'dart:convert';

import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/provider/CartProvider.dart';
import 'package:btl_sem4/services/CartService.dart';
import 'package:flutter/material.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLiked = false;
  String? token;
  final CartService cartService = CartService();
  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  Future<void> checkIfLiked() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    final response = await http.get(
      Uri.parse('${Common.domain}/api/likes/isLiked?productId=${widget.product.id}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        isLiked = json.decode(response.body);
      });
    }
  }

  Future<void> toggleLike() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };

    final url = isLiked
        ? '${Common.domain}/api/likes/remove?productId=${widget.product.id}'
        : '${Common.domain}/api/likes/add?productId=${widget.product.id}';

    final response = isLiked
        ? await http.delete(Uri.parse(url), headers: headers)
        : await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        isLiked = !isLiked; // Toggle the like status
      });
      // Show a message indicating success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLiked ? 'Thích ${widget.product.name}' : 'Bỏ thích ${widget.product.name}'),
        ),
      );
    } else {
      // Handle error case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isLiked ? 'unlike' : 'like'} the product. Please try again.'),
        ),
      );
    }
  }


  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết ${widget.product.name}", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              '${Common.domain}/api/image/${widget.product.image}', // Display product image
              fit: BoxFit.cover,
              height: 350,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Tên sản phẩm : ",
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Giá : '),
                Text(
                  '${widget.product.price.toStringAsFixed(0)}\VND \t',
                  style: TextStyle(fontSize: 20, color: Colors.black26,decoration: TextDecoration.lineThrough),
                ),
                Text(
                  '${widget.product.sale_price.toStringAsFixed(0)}\VND',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.desciption,
                    maxLines: _isExpanded ? null : 3,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isExpanded ? "Show Less" : "Xem thêm",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      cartService.addProductToCart(widget.product.id, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thêm ${widget.product.name} vào giỏ hàng!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Thêm vào giỏ hàng', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: toggleLike,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLiked ? Colors.red : Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isLiked ? 'Đã thích' : 'Thích',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
