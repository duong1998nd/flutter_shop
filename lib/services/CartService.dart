import 'dart:convert';

import 'package:btl_sem4/model/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  String? token;

  Future<void> addProductToCart(int productId, int quantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('chưa đang nhập');
        return;
      }

      final response = await http.post(Uri.parse('${Common.domain}/api/web/cart/items?productId=$productId&quantity=$quantity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Đã thêm vào giỏ hàng');
      } else {
        print('Lỗi');
      }
    } catch (error) {
      print('Error adding product to cart: $error');
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    final url = Uri.parse('${Common.domain}/api/web/cart/items/$cartItemId?quantity=$newQuantity');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode != 200) {
      throw Exception('không update đượcr');
    }
  }

  Future<http.Response> getCart() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };

    print(token);
    return http
        .get(Uri.parse('${Common.domain}/api/web/cart/list'), headers: headers);
  }

  Future<http.Response> findAllByCartId() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    print(token);
    return http
        .get(Uri.parse('${Common.domain}/api/web/cart/list'), headers: headers);
  }

  Future<void> deleteCartItem(int cartItemId) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    final response = await http.delete(Uri.parse('${Common.domain}/api/web/cart/items/$cartItemId'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('chưa xoá được');
    }
  }

}

