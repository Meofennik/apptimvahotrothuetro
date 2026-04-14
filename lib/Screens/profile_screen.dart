import 'package:apptimvahotrothuetro/Screens/post_room_screen.dart';
import 'package:apptimvahotrothuetro/services/user_services.dart';
import 'package:flutter/material.dart';// Import trang đăng tin

class ProfileScreen extends StatelessWidget {
  final int userId = 1; // Trong thực tế bạn lấy ID này từ LoginService sau khi đăng nhập thành công

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserService.getProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        final user = snapshot.data ?? {};

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 60, bottom: 20),
                color: Colors.green,
                width: double.infinity,
                child: Column(
                  children: [
                    CircleAvatar(radius: 50, backgroundImage: NetworkImage(user['avatar'] ?? 'https://via.placeholder.com/150')),
                    SizedBox(height: 10),
                    Text(user['fullname'] ?? "Khách", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(user['email'] ?? "", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              ListTile(leading: const Icon(Icons.post_add, color: Colors.green), title: const Text("Tin đã đăng"), onTap: () {}),
              ListTile(leading: const Icon(Icons.favorite, color: Colors.red), title: const Text("Tin đã lưu"), onTap: () {}),
              ListTile(leading: const Icon(Icons.settings), title: const Text("Cài đặt"), onTap: () {}),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // CHUYỂN SANG TRANG ĐĂNG TIN
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostRoomScreen()),
                    );
                  }, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("ĐĂNG TIN MỚI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}