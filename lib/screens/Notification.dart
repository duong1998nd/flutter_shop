import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hard-coded notification data
    final List<Map<String, String>> notifications = [
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },
      {
        'userName': 'Nguyễn Văn Đại',
        'action': 'Đã đặt hàng',
        'timeAgo': '2 phút trước',
      },

    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo!'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            userName: notification['userName']!,
            action: notification['action']!,
            timeAgo: notification['timeAgo']!,
          );
        },
      ),
    );
  }
}
class NotificationTile extends StatelessWidget {
  final String userName;
  final String action;
  final String timeAgo;

  const NotificationTile({
    required this.userName,
    required this.action,
    required this.timeAgo,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, color: Colors.grey[700]),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            action,
            style: TextStyle(
              fontWeight: FontWeight.normal, // Bạn có thể thay đổi style nếu cần
            ),
          ),
        ],
      ),
      subtitle: Text(timeAgo),
      trailing: Icon(Icons.check_circle, color: Colors.green),
    );
  }
}
