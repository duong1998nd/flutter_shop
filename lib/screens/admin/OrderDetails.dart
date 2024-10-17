import 'package:btl_sem4/model/OrderDTO.dart';
import 'package:btl_sem4/services/OrderService.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  OrderDetailsScreen({required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<OrderDTO> _orderDetails;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _orderDetails = OrderService().fetchOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<OrderDTO>(
        future: _orderDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final order = snapshot.data!;
            if (selectedStatus == null) {
              selectedStatus = order.orderStatus.toUpperCase();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã đơn hàng: ${order.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.0),
                          Text('Địa chỉ: ${order.shippingAddress}'),
                          SizedBox(height: 8.0),
                          Text('Giá: ${order.totalPrice.toStringAsFixed(0)} VNĐ'),
                          SizedBox(height: 8.0),
                          Text('Tình trạng đơn hàng: ${order.orderStatus}', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8.0),
                          Text('Người đặt: ${order.user?.fullname}', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 8.0),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: order.items.length,
                            itemBuilder: (context, index) {
                              final item = order.items[index];
                              return ListTile(
                                leading: Icon(Icons.shopping_cart, color: Colors.teal),
                                title: Text(item.productName),
                                subtitle: Text('Số lượng: ${item.quantity}'),
                                trailing: Text('${item.price.toStringAsFixed(0)} VNĐ'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedStatus,
                    items: <String>['PENDING', 'SHIPPED', 'DELIVERED'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Chọn trạng thái';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                       // Text color
                    ),
                    onPressed: () {
                      _updateOrderStatus(widget.orderId, selectedStatus!);
                    },
                    child: Text('Cập nhật'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Đơn hàng không tồn tại.'));
          }
        },
      ),
    );
  }

  void _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await OrderService().updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thay đổi trạng thái đơn hàng')));

      // Refresh order details after the update
      setState(() {
        _orderDetails = OrderService().fetchOrder(orderId); // Fetch updated order details
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi, hãy thử lại.')));
    }
  }
}
