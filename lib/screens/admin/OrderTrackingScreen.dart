import 'package:btl_sem4/model/OrderDTO.dart';
import 'package:btl_sem4/screens/admin/OrderDetails.dart';
import 'package:btl_sem4/services/OrderService.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả đơn hàng'),
      ),
      body: FutureBuilder<List<OrderDTO>>(
        future: OrderService().fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có đơn hàng'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Mã đơn hàng #${order.id}'),
                    subtitle: Text(
                      'Trạng thái: ${order.orderStatus}\n'
                          'Tổng tiền: ${order.totalPrice.toStringAsFixed(0)} \VNĐ',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(orderId: order.id),
                        ),
                      );

                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
