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
      "name": "$nameController",
      "status": "0"
    };

    var body = json.encode(data);

    var response = await http.post(Uri.parse('${Common.domain}/api/admin/category'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: body);
    print("Lỗi: ${response.statusCode}");
    print("body: ${response.body}");
    return response;
  }

  Future<bool> deleteCategory(int catId) async {
    final url = Uri.parse('${Common.domain}/api/admin/category/$catId');

    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {

        return true;
      } else {
        print('ko xóa dc cat : ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('ko xóa dc cat2: $error');
      return false;
    }
  }
  Future<bool> updateCategoryStatus(int id, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('${Common.domain}/api/admin/category/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
      }),
    );


    if (response.statusCode == 200) {
      return true;
    } else {
      print('ko update được: ${response.statusCode}');
      return false;
    }
  }
}
