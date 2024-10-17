import 'dart:convert';

import 'package:btl_sem4/model/Product.dart';
import 'package:btl_sem4/services/ProductService.dart';
import 'package:flutter/material.dart';

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  List<Product> allProducts = []; // List of all products
  List<Product> filteredProducts = []; // List for filtered products
  TextEditingController searchController = TextEditingController();

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // _loadCurrentUser();
    _loadAllProduct();
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

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Search')),
      body: Column(
        children: [
          Flexible(
            flex: 4,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Nhập tên sách",
                border: InputBorder.none,
              ),
              onSubmitted: (text) {
                String query = searchController.text.trim();
                if (query.isNotEmpty) {
                  _filterProducts(query);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListPage(
                        filteredProducts: filteredProducts,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  final List<Product> filteredProducts;

  ProductListPage({required this.filteredProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kết quả tìm kiếm: ')),
      body: filteredProducts.isEmpty
          ? Center(child: Text('Không có sản phẩm'))
          : ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text('Mã sản phẩm: ${product.id}'),
              onTap: () {
                print(product.name);
                // Handle product tap event here
              },
            ),
          );
        },
      ),
    );
  }
}
