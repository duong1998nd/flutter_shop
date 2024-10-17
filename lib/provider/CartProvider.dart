import 'dart:convert';

import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:btl_sem4/model/CartItem.dart';
import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/services/CartService.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<Product> _products = [];
  double _totalPrice = 0.0;
  bool _isLoading = true;

  List<CartItem> get cartItems => _cartItems;
  List<Product> get products => _products;
  double get totalPrice => _totalPrice;
  bool get isLoading => _isLoading;

  final CartService _cartService = CartService();

  Future<void> loadCart() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _cartService.getCart();
      final data = jsonDecode(response.body) as List;
      _cartItems = data.map((e) => CartItem.fromJson(e)).toList();

      _products = [];
      _totalPrice = 0.0;

      for (CartItem cartItem in _cartItems) {
        final product = await ProductService().getProductById(cartItem.product);
        _products.add(product);
        _totalPrice += product.sale_price * cartItem.quantity;
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      print('load cart lỗi: $error');
      _isLoading = false;
      notifyListeners();
    }
  }

  int getCartLength() {
    return _cartItems.length;
  }

  Future<void> addProductToCart(int productId, int quantity) async {
    try {
      await _cartService.addProductToCart(productId, quantity);
      await loadCart();
    } catch (error) {
      print('Lỗi add cart : $error');
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    try {
      await _cartService.updateCartItemQuantity(cartItemId, newQuantity);
      await loadCart();
    } catch (error) {
      print('Lỗi add qtt: $error');
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    try {
      await _cartService.deleteCartItem(cartItemId);
      await loadCart();
    } catch (error) {
      print('Lỗi xóa : $error');
    }
  }

  double recalculateTotalPrice() {
    double totalPrice = 0.0;
    int length = _cartItems.length < _products.length ? _cartItems.length : _products.length;
    for (int i = 0; i < length; i++) {
      totalPrice += _products[i].sale_price * _cartItems[i].quantity;
    }
    _totalPrice = totalPrice;
    notifyListeners();
    return totalPrice;
  }

}
