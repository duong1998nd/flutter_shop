import 'dart:convert';

import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/provider/CartProvider.dart';
import 'package:btl_sem4/screens/user/ProductDetails.dart';
import 'package:btl_sem4/services/CartService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../user/CartScreen.dart';

class ProductListByCategoryScreen extends StatefulWidget {
  final List<Product> products;
  final String categoryName;
  final int categoryId;

  ProductListByCategoryScreen(
      {required this.products,
      required this.categoryName,
      required this.categoryId});

  @override
  _ProductListByCategoryScreenState createState() =>
      _ProductListByCategoryScreenState();
}

class _ProductListByCategoryScreenState extends State<ProductListByCategoryScreen> {
  List<Product> products = [];
  String? _username;
  final CartService cartService = CartService();
  final ProductService proService = ProductService();
  String? _userRole;

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      List authorities = decodedToken['authorities'];

      print('Decoded JWT: $decodedToken');
      print("${decodedToken['sub']}");
      print("${decodedToken['authorities']}");
      setState(() {
        _username = decodedToken['sub'];
        if (authorities.any((auth) => auth['authority'] == 'USER')) {
          _userRole = "USER";
          print("role: ${_userRole}");
        } else {
          _userRole = "ADMIN";
        }
      });
    } else {
      // Handle case where token is not found
      print("ko load dc user");
    }
  }

  void _loadProducts() async {
    ProductService().getProductByCategoryId(widget.categoryId).then((value) {
      var data =
          jsonDecode(const Utf8Decoder().convert(value.bodyBytes)) as List;
      if (mounted) {
        setState(() {
          products = data.map((e) => Product.fromJson(e)).toList();
        });
      }
      print("cate: ${products.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadProducts(); // Load the products when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục ${widget.categoryName.toLowerCase()} '),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                badges.Badge(
                  badgeContent: Text(
                      context.watch<CartProvider>().getCartLength().toString()
                  ),
                  badgeAnimation: badges.BadgeAnimation.scale(),
                  child: Icon(Icons.shopping_cart),
                )
              ],
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ));
              // Navigate to CartScreen or show cart details
            },
          ),
          SizedBox(width: 5),
        ],
      ),
      body: products.length != 0
          ? ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: product.image != null && product.image.isNotEmpty
                        ? SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              '${Common.domain}/api/image/${product.image}',
                              fit: BoxFit.cover,
                            ),
                          )
                        : SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.image,
                                size: 50),
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    title: Text(product.name),
                    subtitle: Text('Mã sản phẩm: ${product.id}'),
                    trailing: _userRole ==
                            'ADMIN'
                        ? IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red), // Delete icon
                            onPressed: () {
                              // Define the logic to delete the product
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Xoá'),
                                  content: Text(
                                      'Bạn có muốn xoá ${product.name} không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Perform the delete operation
                                        proService.deleteProduct(product.id);
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('Xoá',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : IconButton(onPressed: () {
                          context.read<CartProvider>().addProductToCart(product.id, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm vào giỏ hàng!'),
                            ),
                          );
                          context.read<CartProvider>().recalculateTotalPrice();
                    }, icon: Icon(Icons.add_card)),
                  ),
                );
              },
            )
          : const Text("Danh mục trống",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 50,
                  fontWeight: FontWeight.bold)),
    );
  }
}
