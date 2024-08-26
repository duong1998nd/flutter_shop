import 'dart:convert';

import 'package:btl_sem4/model/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class CategoryService {
  String? token;
  Future<http.Response> getCategories()  {
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
    };
    return http
        .get(Uri.parse('${Common.domain}/api/category'), headers: headers);
  }
  Future<http.Response> addCategory(String nameController) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");
    Map data = {
      "name": "$nameController"
    };
    var body = json.encode(data);

    var response = await http.post(Uri.parse('${Common.domain}/api/admin/category'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: body);
    print("sádsd: ${response.statusCode}");
    print("body: ${response.body}");
    return response;
  }
}
