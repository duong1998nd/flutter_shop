import 'dart:convert';

import 'package:btl_sem4/model/CartItem.dart';
import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/provider/CartProvider.dart';
import 'package:btl_sem4/screens/AccountDetail.dart';
import 'package:btl_sem4/screens/admin/AddProduct.dart';
import 'package:btl_sem4/screens/admin/ProductManagementScreen.dart';
import 'package:btl_sem4/screens/user/CartScreen.dart';
import 'package:btl_sem4/screens/user/CategoryList.dart';
import 'package:btl_sem4/screens/user/HomeContent.dart';
import 'package:btl_sem4/screens/user/LikedScreen.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:btl_sem4/screens/user/MyOrder.dart';
import 'package:btl_sem4/screens/user/ProductSearchScreen.dart';
import 'package:btl_sem4/services/CartService.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int _selectedIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchQuery = '';
    });
    _showSearchDialog();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;

      // Filter products based on the search query
      proByName = products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });

    if (proByName.isNotEmpty) {
      _showSearchDialog();
    }
  }

  final List<Widget> _pages = [
      HomeContent(),
      CategoryList(),
      CartScreen(),
      LikedProductsScreen(),
      ProductManagementScreen(),
  ];

  User? _user;
  String? _username;
  User? infor;
  List<Category> categories = [];
  List<Product> products = [];
  List<Product> proByName = [];
  List<CartItem> myCart = [];
  double totalPrice = 0.0;
  bool isLoading = true;
  int cartQtt = 0;
  TextEditingController searchController = TextEditingController();

  Future<void> _loadCart() async {
    try {
      var response = await CartService().getCart();
      var data = jsonDecode(const Utf8Decoder().convert(response.bodyBytes)) as List;

      if (mounted) {
        setState(() {
          myCart = data.map((e) => CartItem.fromJson(e)).toList();
        });

        double sum = 0.0;
        for (CartItem cartItem in myCart) {
          Product product = await ProductService().getProductById(cartItem.product);
          products.add(product);
          sum += product.price * cartItem.quantity;
          cartQtt = myCart.length;
        }

        setState(() {
          totalPrice = sum;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  @override
  void initState() {
    // _loadCurrentUser();
    _loadProducts();
    fetchUser(_username);
    _loadCategories();
    _loadCart();
    super.initState();
  }


  Future<void> _loadProducts() async {
    // Assuming ProductService is defined and fetches products
    var response = await ProductService().getAllProduct();
    var data = jsonDecode(const Utf8Decoder().convert(response.bodyBytes)) as List;

    // Convert data to Product list
    products = data.map((e) => Product.fromJson(e)).toList();
    proByName = products; // Initialize filtered products
    setState(() {});
  }

  Future<User> fetchUser(String? _username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      print('Decoded JWT: $decodedToken');
      print("name ${decodedToken['sub']}");
      print("role ${decodedToken['authorities']}");
      setState(() {
        _username = decodedToken['sub'];
      });

    final response = await http.get(
      Uri.parse('${Common.domain}/api/account/username=$_username'),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> authorities = decodedToken['authorities'];
      final jsonData = jsonDecode(decodedResponse);
      User user = User.fromJson(jsonData);
      print("üsser: ${user.fullname}");

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

  // Future<void> _loadCurrentUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('jwt_token');
  //
  //   if (token != null) {
  //     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //     print('Decoded JWT: $decodedToken');
  //     print("${decodedToken['sub']}");
  //     print("${decodedToken['authorities']}");
  //     if (mounted) {
  //       setState(() {
  //         _username = decodedToken['sub'];
  //       });
  //     }
  //   } else {
  //     // Handle case where token is not found
  //     print("khong load dc user");
  //   }
  // }
  void _recalculateTotalPrice() {
    double sum = 0.0;
    for (int i = 0; i < myCart.length; i++) {
      sum += products[i].sale_price * myCart[i].quantity;
    }
    setState(() {
      totalPrice = sum;
    });
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

  void _filterProducts(String query) {
    proByName = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _showFilteredProducts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kết quả tìm kiếm"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: proByName.length,
              itemBuilder: (context, index) {
                var product = proByName[index];
                return ListTile(
                  title: Text(product.name),
                  onTap: () {
                    // Handle product click if needed
                    Navigator.pop(context); // Close the dialog
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nhập tên sản phẩm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "VD: Kiêu hãnh và định kiến",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String query = searchController.text.trim();
                  if (query.isNotEmpty) {
                    _filterProducts(query);
                    Navigator.of(context).pop(); // Close the dialog
                    _showFilteredProducts(); // Show filtered products
                  }
                },
                child: Text("Tìm"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Thoát"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          currentIndex = 0;
        });
      },
        shape: CircleBorder(),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.home,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        actions: [
          SizedBox(width: 60),

          SizedBox(width: 10),
          Flexible(
              flex: 4,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    hintText: "Nhập tên sách",
                    border: InputBorder.none
                ),
                onSubmitted: (text) {
                  String query = searchController.text.trim();
                  print("aaa $query");
                  if (query.isNotEmpty) {
                    _filterProducts(query);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(filteredProducts: proByName),
                      ),
                    );
                  }
                },
              )),
          // Expanded(
          //   child: proByName.isEmpty
          //       ? Center(child: Text('No products found'))
          //       : ListView.builder(
          //     itemCount: proByName.length,
          //     itemBuilder: (context, index) {
          //       final product = proByName[index];
          //       return Card(
          //         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //         child: ListTile(
          //           title: Text(product.name),
          //           subtitle: Text('Mã sản phẩm: ${product.id}'),
          //           onTap: () {
          //             print(product.name);
          //           },
          //         ),
          //       );
          //     },
          //   ),
          // ),

          IconButton(
            icon: Icon(Icons.search),
            iconSize: 25,
            onPressed: () {

            }, // Show search dialog when clicked
          ),
          IconButton(
            icon: Stack(
              children: [
                // Icon(Icons.shopping_cart),
                // if (cartQtt > 0) // Show badge only if there's at least one item
                //   Positioned(
                //     right: 0,
                //     top: 0,
                //     child: Container(
                //       padding: EdgeInsets.all(2),
                //       decoration: BoxDecoration(
                //         color: Colors.red,
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       constraints: BoxConstraints(
                //         maxWidth: 20,
                //         maxHeight: 20,
                //       ),
                //       child: Center(
                //         child: Text(
                //           '$cartQtt',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 12,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),

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

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // body: Center(
      //   child: _username == null
      //       ? CircularProgressIndicator()
      //       : Text('Welcome, $_username'),
      //
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // User account header in the drawer
            UserAccountsDrawerHeader(
              accountName: Text("Xin chào ${_user?.fullname}"),
              accountEmail: Text("Email: ${_user?.email}"),
              // decoration: BoxDecoration(
              //   color: Colors.blue,
              // ),
            ),
            // List of menu items
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Trang chủ'),
              onTap: () {
                Navigator.pop(context);  // Closes the drawer
                // Add navigation logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart_rounded),
              title: Text('Đơn hàng '),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserOrdersScreen(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        height: 60,
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {
              setState(() {
                currentIndex = 1;
              });
            }, icon: Icon(
              Icons.grid_view_rounded,
              size: 30,
              color: currentIndex == 1 ? Colors.blue : Colors.grey,
            )),
            IconButton(onPressed: () {
              setState(() {
                currentIndex = 2;
              });
            }, icon: Icon(
              Icons.add_shopping_cart,
              size: 30,
              color: currentIndex == 2 ? Colors.blue : Colors.grey,
            )),
            SizedBox(width: 15),
            IconButton(onPressed: () {
              setState(() {
                currentIndex = 3;
              });
            }, icon: Icon(
              Icons.favorite,
              size: 30,
              color: currentIndex == 3 ? Colors.blue : Colors.grey,
            )),
            IconButton(onPressed: () {
              setState(() {
                currentIndex = 4;
              });
            }, icon: Icon(
              Icons.call_merge,
              size: 30,
              color: currentIndex == 4 ? Colors.blue : Colors.grey,
            )),
          ],
        ),
      ),
      body:
      _pages[currentIndex],
      //
      // bottomNavigationBar:
      // BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.home,
      //         size: 30,
      //       ),
      //       label: 'Home'
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.category,
      //         size: 30,
      //       ),
      //       label: 'Category',
      //     ),
      //
      //
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.person_2_outlined,
      //         size: 30,
      //       ),
      //       label: 'Account',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.add_shopping_cart,
      //         size: 30,
      //       ),
      //       label: 'AAA',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   onTap: _onItemTapped,
      // )
      // ,
    );
  }
}

