import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Order Management', style: TextStyle(fontSize: 24)),
            // Add buttons or list views to manage orders
            ElevatedButton(
              onPressed: () {
                // Handle view all orders
              },
              child: Text('View All Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
