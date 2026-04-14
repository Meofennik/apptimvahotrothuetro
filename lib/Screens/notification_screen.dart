import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {"title": "Tin đăng đã được duyệt", "content": "Phòng trọ tại Ngô Xuân Quảng của bạn đã được hiển thị.", "time": "2 giờ trước"},
    {"title": "Có tin nhắn mới", "content": "Nguyễn Văn B vừa nhắn tin cho bạn về phòng trọ.", "time": "5 giờ trước"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.2), child: Icon(Icons.notifications, color: Colors.green)),
            title: Text(notifications[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notifications[index]['content']!),
            trailing: Text(notifications[index]['time']!, style: TextStyle(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }
}