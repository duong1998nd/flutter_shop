import 'dart:convert';
import 'package:btl_sem4/model/OrderDTO.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Future<List<OrderDTO>> fetchOrders() async {
    final response = await http.get(Uri.parse('${Common.domain}/api/order'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(decodedBody);

      return data.map((json) => OrderDTO.fromJson(json)).toList();
    } else {
      throw Exception('Không load được đơn hàng');
    }
  }

  Future<OrderDTO> fetchOrder(int orderId) async {
    final response = await http.get(Uri.parse('${Common.domain}/api/order/$orderId'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return OrderDTO.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Không load được đơn hàng');
    }
  }

  Future<List<OrderDTO>> fetchOrdersByStatus(String status) async {
    final response = await http.get(Uri.parse('${Common.domain}/api/order/status/$status'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => OrderDTO.fromJson(order)).toList();
    } else {
      throw Exception('Lỗi ko load được order');
    }
  }


  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse('${Common.domain}/api/order/$orderId/status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': newStatus,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }

  String? token;
  Future<List<OrderDTO>> getMyOrder() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    final response = await http.get(
      Uri.parse('${Common.domain}/api/order/myOder'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => OrderDTO.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load my orders');
    }
  }

  // Future<List<OrderDTO>> fetchOrdersByStatus(String status) async {
  //   final response = await http.get(Uri.parse('${Common.domain}/api/order/status/$status'));
  //
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((order) => OrderDTO.fromJson(order)).toList();
  //   } else {
  //     throw Exception('Failed to load orders');
  //   }
  // }
}
