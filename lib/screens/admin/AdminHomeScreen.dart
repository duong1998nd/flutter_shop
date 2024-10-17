import 'package:btl_sem4/screens/admin/AddCategory.dart';
import 'package:btl_sem4/screens/admin/AddProduct.dart';
import 'package:btl_sem4/screens/admin/CategoryMangementScreen.dart';
import 'package:btl_sem4/screens/admin/OrderTrackingScreen.dart';
import 'package:btl_sem4/screens/admin/TestOrders.dart';
import 'package:btl_sem4/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:btl_sem4/screens/admin/ProductManagementScreen.dart';
import 'package:btl_sem4/screens/admin/OrderManagementScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CategoryManagementScreen(),
    ProductManagementScreen(),
    OrderStatusScreen(status: 'PENDING'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Trang quản trị'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text('Quản lý danh mục'),
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);  // close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text('Quản lý sản phẩm'),
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Quản lý đơn hàng'),
                onTap: () {
                  _onItemTapped(2);
                  Navigator.pop(context);  // close the drawer
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
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Danh mục',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Sản phẩm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Đơn hàng',
            ),
          ],

          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
