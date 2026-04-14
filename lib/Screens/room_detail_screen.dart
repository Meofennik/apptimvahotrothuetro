import 'package:flutter/material.dart';


class RoomDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.network('https://via.placeholder.com/400x300', height: 300, width: double.infinity, fit: BoxFit.cover),
              Positioned(top: 40, left: 10, child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back))),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phòng trọ khép kín 25m2...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("3.500.000 đ/tháng", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("📍 Ngõ 45 Ngô Xuân Quảng, Gia Lâm, Hà Nội"), // Địa chỉ gần VNUA [cite: 85]
              ],
            ),
          ),
          Spacer(),
          // Nút liên hệ dưới cùng [cite: 85]
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: (){}, child: Text("Nhắn tin"))),
              Expanded(child: ElevatedButton(onPressed: (){}, child: Text("Gọi điện"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
            ],
          )
        ],
      ),
    );
  }
}