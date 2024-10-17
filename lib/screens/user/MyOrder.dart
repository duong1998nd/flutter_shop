import 'package:btl_sem4/model/OrderDTO.dart';
import 'package:btl_sem4/services/OrderService.dart';
import 'package:flutter/material.dart';

class UserOrdersScreen extends StatefulWidget {
  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  late Future<List<OrderDTO>> _futureOrders;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _futureOrders = _orderService.getMyOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đơn hàng của tôi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderDTO>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No orders found.',
                style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          List<OrderDTO> orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.tealAccent,
                elevation: 8,
                child: ListTile(
                  leading: Icon(Icons.receipt_long, color: Colors.teal),
                  title: Text(
                    'Mã đơn hàng #${order.id}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  subtitle: Text(
                    'Tình trạng: ${order.orderStatus}\nTổng tiền: ${order.totalPrice.toStringAsFixed(0)} VNĐ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${order.items.length} sản phẩm',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
