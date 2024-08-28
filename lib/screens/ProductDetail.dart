import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName = "Tên sản phẩm";
  final String productDescription = "Ebook miễn phí có sẵn ở đây có thể giúp bạn với một loạt các vấn đề lớn sẽ cải thiện cuộc sống của bạn theo nhiều cách. Nó có thể giúp bạn buông bỏ những tình huống đau đớn từ quá khứ và đối mặt với tương lai với thái độ hạnh phúc và tích cực hơn. Nó có thể giúp bạn cảm thấy tốt hơn về bản thân, cảm thấy tốt hơn về những người bạn biết (và những người bạn đã biết) và cảm thấy tốt hơn về cuộc sống. Khi tôi bắt đầu sử dụng các phương pháp trong cuốn sách này, cuộc sống của tôi đã thay đổi đáng kể – tốt hơn – và cứ tiếp tục như vậy.";
  final double productPrice = 1000;
  final String productImage =
      "https://via.placeholder.com/400x300.png?text=Product+Image";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push; // Quay về trang trước đó
          },
        ),
        title: Text('Chi tiết sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Product Image
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmg8V3EW8Wk2vKMdxpDG8wzYgGAjnjii4IUQ&s',),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {
                      // Handle favorite button action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thêm vào yêu thích')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Product Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Giá sản phẩm:${productPrice.toStringAsFixed(3)} VNĐ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Product Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                productDescription,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            // Add to Cart Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: ElevatedButton(
            onPressed: () {
              // Handle add to cart action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thêm vào giỏ hàng')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              minimumSize: Size(double.infinity, 60), // Width full screen, height 60
              textStyle: TextStyle(fontSize: 18),
              backgroundColor: Colors.red,// Text size
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Thêm vào giỏ hàng'),
                SizedBox(width: 8), // Space between text and icon
                Icon(Icons.shopping_cart),
              ],
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}
