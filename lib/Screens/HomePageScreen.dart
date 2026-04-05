import 'package:apptimvahotrothuetro/widgets/room_grid.dart';
import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/category_list.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 1. Header (Đã tách ra file riêng)
          const HomeHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Danh mục (Đã tách ra file riêng)
                  const CategoryList(),

                  // 3. Tiêu đề phần tin đăng
                  _buildSectionTitle(context),

                  // 4. Lưới phòng trọ (Đã tách ra file riêng)
                  const RoomGrid(), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Tiêu đề: Tin đăng mới nhất
  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Tin đăng mới nhất",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Xem tất cả >", style: TextStyle(color: Color(0xFF37DD63))),
          ),
        ],
      ),
    );
  }

  // Thanh điều hướng dưới cùng
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF37DD63),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Quản lý"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Thông báo"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
      ],
    );
  }
}