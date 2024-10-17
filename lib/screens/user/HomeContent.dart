import 'dart:convert';

import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/admin/ScreenProduct.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:btl_sem4/screens/user/ProductDetails.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final List<String> imgList = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];
  User? _user;
  String? _username;
  User? infor;
  List<Category> categories = [];
  List<Product> products = [];
  bool showAllCategories = false;

  @override
  void initState() {
    super.initState();
    // _loadCurrentUser();
    fetchUser(_username);
    _loadCategories();
    _loadAllProduct();
  }

  Future<User> fetchUser(String? _username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    print('Decoded JWT: $decodedToken');
    print("name ${decodedToken['sub']}");
    print("role ${decodedToken['authorities']}");
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
      print("Tên: ${user.fullname}");
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
        });
      }
      print("cate: ${categories.length}");
    });
  }

  void _loadAllProduct() async {
    ProductService().getAllProduct().then((value) {
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

  // Future<void> _loadCurrentUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('jwt_token');
  //
  //   if (token != null) {
  //     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //     print('Decoded JWT: $decodedToken');
  //     print("${decodedToken['sub']}");
  //     print("${decodedToken['authorities']}");
  //     setState(() {
  //       _username = decodedToken['sub'];
  //     });
  //   } else {
  //     // Handle case where token is not found
  //     print("Lỗi homecontent");
  //   }
  // }
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                initialPage: 0,
              ),
              items: imgList
                  .map((item) => Container(margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(item, fit: BoxFit.cover),
                ),
              ))
                  .toList(),
            ),
            // Categories Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Danh mục sách :',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.teal),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllCategories = !showAllCategories; // Toggle showAll
                          });
                        },
                        child: Text(
                          showAllCategories ? 'Ẩn bớt <<< ' : 'Xem tất cả >>>',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),

                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  SizedBox(height: 8),
                  // ListView.builder(
                  //     shrinkWrap: true,
                  //     primary: false,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: categories.length,
                  //     itemBuilder: (context, int index) {
                  //       var cat = categories[index];
                  //       return ElevatedButton(
                  //           style: const ButtonStyle(
                  //               backgroundColor:
                  //               MaterialStatePropertyAll<Color>(Colors.green)),
                  //           onPressed: () {
                  //             // Navigator.of(context).push(MaterialPageRoute(
                  //             //     builder: (context) => ScreenProduct(cat: cat)));
                  //           },
                  //           child: Text(
                  //             cat.name,
                  //             style: const TextStyle(fontSize: 20),
                  //           ));
                  //     }),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.isNotEmpty
                        ? (showAllCategories ? categories.length : 2)
                        : 0,
                    itemBuilder: (context, index) {
                      if (index >= categories.length) {
                        return SizedBox();
                      }
                      var cat = categories[index];
                      return GestureDetector(
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
                            print(cat.id);
                            print("số lượng sp: ${products.length}");
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
                          });// Handle category click
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              cat.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Products Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xem gần đây:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: products.isNotEmpty ? products.length : 0,
                    itemBuilder: (context, index) {
                      if (index >= products.length) {
                        return SizedBox(); // Return empty if index is out of bounds
                      }
                      var pro = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: pro),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.network(
                                  '${Common.domain}/api/image/${pro.image}',
                                  // Replace with actual product image
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pro.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
