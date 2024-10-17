import 'dart:convert';

import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ProductService {
  String? token;
  Future<List<Product>> getProductByName() async {
    final response = await http.get(
      Uri.parse('${Common.domain}/api/products'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Ko load được sản phẩm');
    }
  }


  Future<http.Response> getAllProduct() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
    };

    return http
        .get(Uri.parse('${Common.domain}/api/product'), headers: headers);
  }

  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse("${Common.domain}/api/admin/product");
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((productJson) => Product.fromJson(productJson)).toList();
      } else {
        throw Exception('ko load được sp');
      }
    } catch (error) {
      print('Error fetching products: $error');
      return [];
    }
  }

  Future<Product> getProductById(int productId) async {
    final response = await http.get(Uri.parse('${Common.domain}/api/product/$productId'));

    if (response.statusCode == 200) {
      final decodedBody = const Utf8Decoder().convert(response.bodyBytes);
      final jsonData = jsonDecode(decodedBody);
      return Product.fromJson(jsonData);
    } else {
      throw Exception('ko load được product ID $productId');
    }
  }

  Future<http.Response> getProductByCategoryId(int catId)  {
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
    };

    return http
        .get(Uri.parse('${Common.domain}/api/product/categoryId=$catId'), headers: headers);
  }

  Future<http.StreamedResponse> save(Product pro, String method, bool hasFile, String filePath) async{
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");
    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer $token"
    };
    print(token);

    var uri=method=='POST'?'product':'product/${pro.id}';
    var request = await http.MultipartRequest(
        method, Uri.parse('${Common.domain}/api/admin/$uri')) ;

    request.headers.addAll(headers);

    if (!hasFile) {
      request.files.add(http.MultipartFile.fromBytes(
          "file", [],
          filename: ""));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
          "file", filePath));
    }
    print(pro.name);
    print("image: ${pro.image}");
    print(filePath);
    request.fields.addAll(pro.toMap());
    return request.send();
  }

  Future<bool> deleteProduct(int productId) async {
    final url = Uri.parse('${Common.domain}/api/admin/product?id=$productId');

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
        print('Failed to delete product: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error deleting product: $error');
      return false;
    }
  }

}

