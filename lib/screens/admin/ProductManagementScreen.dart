import 'dart:convert';
import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/admin/AddCategory.dart';
import 'package:btl_sem4/screens/admin/AddProduct.dart';
import 'package:btl_sem4/screens/admin/ScreenProduct.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:btl_sem4/screens/user/ProductDetails.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:number_paginator/number_paginator.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagementScreen> {
  User? _user;
  String? _username;
  List<Product> products = [];
  List<Product> paginatedProducts = [];
  int currentPage = 0;
  final int itemsPerPage = 6;
  ProductService proService = new ProductService();

  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadAllProduct();
  }

  Future<void> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    _username = decodedToken['sub'];

    final response = await http.get(
      Uri.parse('${Common.domain}/api/account/username=$_username'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      _user = User.fromJson(jsonData);
    } else {
      throw Exception('Failed to load user');
    }
  }

  void _loadAllProduct() async {
    var value = await ProductService().getAllProduct();
    var data = jsonDecode(const Utf8Decoder().convert(value.bodyBytes)) as List;

    setState(() {
      products = data.map((e) => Product.fromJson(e)).toList();
      _updatePaginatedProducts();
    });
  }

  void _updatePaginatedProducts() {
    final int start = currentPage * itemsPerPage;
    final int end = (start + itemsPerPage > products.length) ? products.length : start + itemsPerPage;
    paginatedProducts = products.sublist(start, end);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (products.isEmpty ? 1 : (products.length / itemsPerPage).ceil());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Tất cả sản phẩm", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        floatingActionButton: _user?.role == 'ADMIN'
            ? FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewProductForm(),
            )).then((value) {
              setState(() {});
            });
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.orangeAccent,
        )
            : null,
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paginatedProducts.length,
                itemBuilder: (context, index) {
                  final pro = paginatedProducts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.lightBlue[50],
                    child: ListTile(
                      title: Text(
                        pro.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      trailing: _user?.role == 'ADMIN'
                          ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Xác nhận"),
                                content: Text("Bạn có chắc chắn muốn xoá không?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Không"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      proService.deleteProduct(pro.id);
                                      Navigator.of(context).pop();
                                      _loadAllProduct();
                                    },
                                    child: Text("Chắc"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                          : null,
                      subtitle: Row(
                        children: [
                          Text('Giá : '),
                          Text(
                            '${pro.price.toStringAsFixed(0)}\VND \t',
                            style: TextStyle(fontSize: 16, color: Colors.black26,decoration: TextDecoration.lineThrough),
                          ),
                          Text(
                            '${pro.sale_price.toStringAsFixed(0)}\VND',
                            style: TextStyle(fontSize: 20, color: Colors.green),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: pro),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: NumberPaginator(
                numberPages: totalPages,
                initialPage: currentPage,
                onPageChange: (int index) {
                  setState(() {
                    currentPage = index;
                    _updatePaginatedProducts();
                  });
                },
                config: NumberPaginatorUIConfig(
                  buttonSelectedBackgroundColor: Colors.teal,
                  buttonUnselectedForegroundColor: Colors.black,
                  buttonSelectedForegroundColor: Colors.white,
                  buttonUnselectedBackgroundColor: Colors.grey.shade300,
                  buttonShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  buttonPadding: EdgeInsets.all(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
