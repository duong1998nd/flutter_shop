import 'package:btl_sem4/model/OrderDTO.dart';
import 'package:btl_sem4/screens/admin/OrderDetails.dart';
import 'package:btl_sem4/services/OrderService.dart';
import 'package:flutter/material.dart';

class OrderStatusScreen extends StatefulWidget {
  final String status;

  OrderStatusScreen({required this.status});

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late Future<List<OrderDTO>> futureOrders;
  OrderService orderService = new OrderService();

  @override
  void initState() {
    super.initState();
    futureOrders = orderService.fetchOrdersByStatus(widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tình Trạng Đơn Hàng'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                futureOrders = orderService.fetchOrdersByStatus(value);
              });
            },
            itemBuilder: (BuildContext context) {
              return ['PENDING', 'SHIPPED', 'DELIVERED', 'CANCELED']
                  .map((String status) {
                return PopupMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100], // Light background color
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<OrderDTO>>(
          future: futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Không có đơn hàng nào.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            List<OrderDTO> orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      'Mã đơn hàng: ${order.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tình trạng: ${order.orderStatus}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Giá: ${order.totalPrice.toStringAsFixed(0)} VNĐ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Địa chỉ nhận hàng: ${order.shippingAddress}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsScreen(orderId: order.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
