import 'dart:convert';

import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/AccountDetail.dart';
import 'package:btl_sem4/screens/HomeContent.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      _searchQuery = ' ';
    });
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
    });
  }

  
  final List<Widget> _pages = [
      HomeContent(),
      AccountDetail(),
      Text("Trang 3"),
      Text("Trang 4"),
  ];

  final List<String> imgList = [
    'https://via.placeholder.com/800x400', // Replace with your images
    'https://via.placeholder.com/800x400',
    'https://via.placeholder.com/800x400',
  ];
  User? _user;
  String? _username;
  User? infor;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCategories();
  }

  Future<User> fetchUser(String _username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      print('Decoded JWT: $decodedToken');
      print("${decodedToken['sub']}");
      print("${decodedToken['authorities']}");
      setState(() {
        _username = decodedToken['sub'];
      });

    final response = await http.get(
      Uri.parse('${Common.domain}/api/account/username=$_username'),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
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
      setState(() {
        categories = data.map((e) => Category.fromJson(e)).toList();
      });
      print("cate: ${categories.length}");
    });
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print('Decoded JWT: $decodedToken');
      print("${decodedToken['sub']}");
      print("${decodedToken['authorities']}");
      setState(() {
        _username = decodedToken['sub'];
      });
    } else {
      // Handle case where token is not found
      Navigator.of(context).pop();
    }
  }
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

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
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: _updateSearchQuery,
        )
            : Text('Shop'),
        actions: [
          _isSearching
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: _stopSearch,
          )
              : IconButton(
            icon: Icon(Icons.search),
            onPressed: _startSearch,
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
            DrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                child:
                  Text("ádsaad"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("aaaa"),
              onTap: () {
                fetchUser;
                // Handle profile navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Đăng ký'),
              onTap: () {
                // Handle profile navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                // Handle profile navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      // SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       // Carousel Section
      //       CarouselSlider(
      //         options: CarouselOptions(
      //           height: 200.0,
      //           autoPlay: true,
      //           enlargeCenterPage: true,
      //           viewportFraction: 0.9,
      //           aspectRatio: 16 / 9,
      //           initialPage: 0,
      //         ),
      //         items: imgList.map((item) => Container(
      //           child: Center(
      //             child: Image.network(item, fit: BoxFit.cover, width: 1000),
      //           ),
      //         )).toList(),
      //       ),
      //
      //       // Categories Section
      //       Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Danh mục sách :',
      //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //             ),
      //             SizedBox(height: 8),
      //             // ListView.builder(
      //             //     shrinkWrap: true,
      //             //     primary: false,
      //             //     physics: const NeverScrollableScrollPhysics(),
      //             //     itemCount: categories.length,
      //             //     itemBuilder: (context, int index) {
      //             //       var cat = categories[index];
      //             //       return ElevatedButton(
      //             //           style: const ButtonStyle(
      //             //               backgroundColor:
      //             //               MaterialStatePropertyAll<Color>(Colors.green)),
      //             //           onPressed: () {
      //             //             // Navigator.of(context).push(MaterialPageRoute(
      //             //             //     builder: (context) => ScreenProduct(cat: cat)));
      //             //           },
      //             //           child: Text(
      //             //             cat.name,
      //             //             style: const TextStyle(fontSize: 20),
      //             //           ));
      //             //     }),
      //             GridView.builder(
      //               shrinkWrap: true,
      //               physics: NeverScrollableScrollPhysics(),
      //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //                 crossAxisCount: 2,
      //                 childAspectRatio: 3 / 2,
      //                 crossAxisSpacing: 10,
      //                 mainAxisSpacing: 10,
      //               ),
      //               itemCount: categories.length,
      //               itemBuilder: (context, index) {
      //                 var cat = categories[index];
      //                 return GestureDetector(
      //                   onTap: () {
      //                     // Handle category click
      //                   },
      //                   child: Card(
      //                     child: Center(
      //                       child: Text(
      //                         cat.name,
      //                         style: const TextStyle(fontSize: 16),
      //                       ),
      //                     ),
      //                   ),
      //                 );
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //
      //       // Products Section
      //       Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Sách mới :',
      //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //             ),
      //             SizedBox(height: 8),
      //             GridView.builder(
      //               shrinkWrap: true,
      //               physics: NeverScrollableScrollPhysics(),
      //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //                 crossAxisCount: 2,
      //                 childAspectRatio: 3 / 4,
      //                 crossAxisSpacing: 10,
      //                 mainAxisSpacing: 10,
      //               ),
      //               itemCount: 6,
      //               itemBuilder: (context, index) {
      //                 return GestureDetector(
      //                   onTap: () {
      //                     // Handle product click
      //                   },
      //                   child: Card(
      //                     elevation: 5,
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.stretch,
      //                       children: [
      //                         Expanded(
      //                           child: Image.network(
      //                             'https://via.placeholder.com/400x400', // Replace with actual product image
      //                             fit: BoxFit.cover,
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: Text(
      //                             'Product ${index + 1}',
      //                             style: TextStyle(fontWeight: FontWeight.bold),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // Footer Section
      bottomNavigationBar:
      // BottomAppBar(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Text(
      //       'Bởi vì sách là thế giới',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 16),
      //     ),
      //   ),
      // ),
      BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_rounded),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'AAA',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      )
      ,
    );
  }
}

