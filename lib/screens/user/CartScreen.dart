import 'dart:convert';

import 'package:btl_sem4/model/Cart.dart';
import 'package:btl_sem4/model/CartItem.dart';
import 'package:btl_sem4/model/OrderItem.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/provider/CartProvider.dart';
import 'package:btl_sem4/screens/user/OrderScreen.dart';
import 'package:btl_sem4/services/CartService.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> myCart = [];
  List<Product> products = [];
  double totalPricel = 0.0;
  bool isLoading = true;
  User? _user;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadCart();
    fetchUser(_username);
  }

  void _recalculateTotalPrice() {
    double sum = 0.0;
    for (int i = 0; i < myCart.length; i++) {
      sum += products[i].sale_price * myCart[i].quantity;
    }
    setState(() {
      totalPricel = sum;
    });
  }

  void _updateQuantity(int index, int change) async {
    setState(() {
      myCart[index].quantity += change;
      _recalculateTotalPrice();
    });

    if (myCart[index].quantity <= 0) {
      _confirmDeleteCartItem(index);
    } else {
      try {
        await CartProvider().updateCartItemQuantity(myCart[index].id, myCart[index].quantity);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Số lượng sản phẩm đã thay đổi'),
          backgroundColor: Colors.blue,
        ));
      } catch (error) {
        setState(() {
          myCart[index].quantity -= change;
          _recalculateTotalPrice();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không thay đổi được số lượng sản phẩm, thử lại.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _deleteCartItem(int index) async {
    try {
      await CartService().deleteCartItem(myCart[index].id);
      setState(() {
        myCart.removeAt(index);
        products.removeAt(index);
      });
      _recalculateTotalPrice();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sản phẩm đã được xóa khỏi giỏ hàng'),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Không thể xóa sản phẩm, thử lại.'),
        backgroundColor: Colors.red,
      ));
    }
  }

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

  void _loadCart() async {
    try {
      var response = await CartService().getCart();

      if (response.statusCode != 200) {
        return; // Early return on error
      }

      var data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is List) {
        myCart = data.map((e) => CartItem.fromJson(e)).toList();
      }

      products.clear();
      for (CartItem cartItem in myCart) {
        Product product = await ProductService().getProductById(cartItem.product);
        products.add(product);
      }

      _recalculateTotalPrice();
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false; // Ensure loading is updated on error
      });
    }
  }

  Future<void> _confirmDeleteCartItem(int index) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Có'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteCartItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng', style: TextStyle(color: Colors.grey),),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  Product product = products[index];
                  CartItem cart = myCart[index];

                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await _confirmDeleteCartItem(index);
                    },
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.only(right: 20.0),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Giá khuyến mãi: ${product.sale_price.toStringAsFixed(0)} VNĐ'),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              '${Common.domain}/api/image/${product.image}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateQuantity(index, -1);
                              },
                            ),
                            Text('${cart.quantity}', style: TextStyle(fontSize: 18)),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(index, 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tổng tiền: ${totalPricel.toStringAsFixed(0)} VNĐ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Thanh toán', style: TextStyle(color: Colors.white, fontSize: 25)),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  fixedSize: Size(400, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(
                        cartItems: myCart.map((cartItem) => OrderItem(
                            productId: cartItem.product,
                            quantity: cartItem.quantity)).toList(),
                        totalPrice: totalPricel,
                        userId: _user!.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
