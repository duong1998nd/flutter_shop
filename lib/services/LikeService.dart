import 'package:btl_sem4/model/common.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LikeService {

  String? token;

  Future<void> addLike(int productId) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    final response = await http.post(
      Uri.parse('${Common.domain}/api/likes/add?productId=${productId}'),
      headers: headers,
      body: json.encode([productId]),
    );

    if (response.statusCode != 200) {
      throw Exception('Like ko được');
    }
  }

}
