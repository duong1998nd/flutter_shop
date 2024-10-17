import 'dart:convert';

import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/admin/AddCategory.dart';
import 'package:btl_sem4/screens/admin/CategoryEdit.dart';
import 'package:btl_sem4/screens/admin/ScreenProduct.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:number_paginator/number_paginator.dart';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementState  createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagementScreen> {
  User? _user;
  String? _username;
  User? infor;
  List<Category> categories = [];
  List<Product> products = [];
  int currentPage = 0;
  int itemsPerPage = 7;
  Map<int, int> productCounts = {};
  CategoryService catService = new CategoryService();
  @override
  void initState() {
    super.initState();
    // _loadCurrentUser();
    fetchUser(_username);
    _loadCategories();
  }

  Future<User> fetchUser(String? _username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    print('Decoded JWT: $decodedToken');
    print("name ${decodedToken['sub']}");
    print("role ${decodedToken['authorities']}");
    if(mounted) {
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
      _fetchProductCounts();
    });
  }

  Future<void> _fetchProductCounts() async {
    for (var category in categories) {
      final response = await ProductService().getProductByCategoryId(category.id);
      var data = jsonDecode(const Utf8Decoder().convert(response.bodyBytes)) as List;
      if (mounted) {
        setState(() {
          productCounts[category.id] = data.length;
        });
      }
    }
  }

  Future<void> _updateCategoryStatus(int categoryId, int status) async {
    bool success = await catService.updateCategoryStatus(categoryId, status);
    if (success) {
      setState(() {
        categories.firstWhere((cat) => cat.id == categoryId).status = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thay đổi trạng thái danh mục thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không được rồi')),
      );
    }
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
    int totalPages = (categories.isEmpty ? 1 : (categories.length / itemsPerPage).ceil());
    List<Category> paginatedCategories = categories
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      appBar: AppBar(
        title: Text("Danh mục sản phẩm"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => CategoryForm()))
                  .then((value) {
                setState(() {

                });
              });
            },
            child: const Icon(Icons.add_box)),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paginatedCategories.length,
                itemBuilder: (context, index) {
                  final category = paginatedCategories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(category.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Số lượng sản phẩm: ${productCounts[category.id] ?? 0}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: category.status,
                            items: [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('Còn hàng'),
                              ),
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Hết hàng'),
                              ),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                _updateCategoryStatus(category.id, newStatus);
                              }
                            },
                          ),

                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (category.status != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Danh mục có chứa sản phẩm, không thể xóa')),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Xác nhận"),
                                      content: Text("Bạn có chắc chắn muốn xóa không?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Không"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            catService.deleteCategory(category.id).then((_) {
                                              setState(() {
                                                categories.removeWhere((cat) => cat.id == category.id);
                                              });
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Xóa"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      onTap: () {
                        ProductService()
                            .getProductByCategoryId(category.id)
                            .then((value) {
                          var data = jsonDecode(const Utf8Decoder()
                              .convert(value.bodyBytes)) as List;
                          if (mounted) {
                            setState(() {
                              products = data.map((e) => Product.fromJson(e)).toList();
                              print(data.length);
                              productCounts[category.id] = data.length;
                            });
                          }
                        });
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) => ProductListByCategoryScreen(
                              products: products,
                              categoryName: category.name,
                              categoryId: category.id,
                            )))
                            .then((value) {
                          setState(() {});
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            NumberPaginator(
              // config: NumberPaginatorUIConfig(
              //   buttonShape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   buttonSelectedBackgroundColor: Colors.blue,
              //   buttonUnselectedForegroundColor: Colors.black,
              //   buttonSelectedForegroundColor: Colors.white,
              //   buttonUnselectedBackgroundColor: Colors.grey.shade300,
              //   buttonPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              // ),
              // numberPages: totalPages,
              // onPageChange: (int index) {
              //   setState(() {
              //     currentPage = index;
              //   });
              // },
              numberPages: totalPages,  // Ensure numberPages is at least 1
              initialPage: currentPage,  // Make sure currentPage is initialized properly
              onPageChange: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
              config: NumberPaginatorUIConfig(
                buttonSelectedBackgroundColor: Colors.blue,
                buttonUnselectedForegroundColor: Colors.black,
                buttonSelectedForegroundColor: Colors.white,
                buttonUnselectedBackgroundColor: Colors.grey.shade300,
                buttonShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                buttonPadding: EdgeInsets.all(5),
              ),

            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.navigation),
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.white,
      //   onPressed: () => {},
      // ),
      /*floatingActionButton:FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.save),
        label: Text("Save"),
      ), */
    ),
    );
  }

}
