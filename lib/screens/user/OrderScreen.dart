import 'dart:convert';
import 'package:btl_sem4/model/OrderItem.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class OrderScreen extends StatefulWidget {
  final List<OrderItem> cartItems;
  final double totalPrice;
  final int userId;

  OrderScreen({required this.cartItems, required this.totalPrice, required this.userId});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;


  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Order newOrder = Order(
        userId: widget.userId,
        shippingAddress: _addressController.text,
        items: widget.cartItems,
        totalPrice: widget.totalPrice,
      );

      String? token;
      final pref = await SharedPreferences.getInstance();
      token = pref.getString("token");
      var response = await http.post(
        Uri.parse('${Common.domain}/api/order/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newOrder.toJson()),
      );

      if (response.statusCode == 200) {
        // Order successfully created
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đặt thành công!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi 1!'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      print('Lỗi: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi 2.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xác nhận đặt hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Nhập địa chỉ nhận hàng',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Tổng tiền: ${widget.totalPrice.toStringAsFixed(0)} VNĐ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _placeOrder,
              child: Text('Đặt hàng'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
