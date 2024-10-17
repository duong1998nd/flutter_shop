import 'dart:convert';
import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/admin/ScreenProduct.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> categories = [];
  List<Product> products = [];
  User? _user;
  String? _username;
  bool isLoading = true;

  Future<User> fetchUser(String? _username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    if (mounted) {
      setState(() {
        _username = decodedToken['sub'];
      });
    }
    final response = await http.get(
      Uri.parse('${Common.domain}/api/account/username=$_username'),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedResponse);
      User user = User.fromJson(jsonData);
      _user = user;
      return user;
    } else {
      throw Exception('Failed to load user');
    }
  }

  void _loadCategories() async {
    CategoryService().getCategories().then((value) {
      var data =
      jsonDecode(const Utf8Decoder().convert(value.bodyBytes)) as List;
      if (mounted) {
        setState(() {
          categories = data.map((e) => Category.fromJson(e)).toList();
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser(_username);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục sản phẩm'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            color: cat.status == 1 ? Colors.lightGreen[100] : Colors.red[100],
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                cat.status == 1 ? Icons.check_circle : Icons.cancel,
                color: cat.status == 1 ? Colors.green : Colors.red,
              ),
              title: Text(
                cat.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(cat.status == 1 ? 'Còn hàng' : 'Hết hàng'),
              onTap: () {
                ProductService()
                    .getProductByCategoryId(cat.id)
                    .then((value) {
                  var data = jsonDecode(const Utf8Decoder()
                      .convert(value.bodyBytes)) as List;
                  if (mounted) {
                    setState(() {
                      products = data
                          .map((e) => Product.fromJson(e))
                          .toList();
                    });
                  }
                });
                Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (context) =>
                        ProductListByCategoryScreen(
                          products: products,
                          categoryName: cat.name,
                          categoryId: cat.id,
                        )))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
          );
        },
      ),
    );
  }
}
