import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/category_list.dart';
import '../widgets/room_grid.dart';

// Import các trang để nhúng vào Tab
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'management_screen.dart';

class HomePageScreen extends StatefulWidget {
  final bool isGuest; 

  const HomePageScreen({super.key, this.isGuest = false}); 

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;
  
  // 1. Thêm biến để lưu trữ cố định danh sách các màn hình
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 2. Khởi tạo danh sách màn hình 1 lần duy nhất khi mở App
    _screens = widget.isGuest ? _guestScreens() : _userScreens();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      // 3. SỬ DỤNG IndexedStack ĐỂ GIỮ NGUYÊN TRẠNG THÁI CÁC TAB
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // DANH SÁCH MÀN HÌNH CHO USER
  List<Widget> _userScreens() {
    return [
      _buildHomeContent(), 
      const ManagementScreen(),
      NotificationScreen(), 
      ProfileScreen(),      
    ];
  }

  // DANH SÁCH MÀN HÌNH CHO KHÁCH (GUEST)
  List<Widget> _guestScreens() {
    return [
      _buildHomeContent(), 
      _buildGuestProfile(), 
    ];
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        const HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CategoryList(),
                _buildSectionTitle(context),
                const RoomGrid(), 
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Bạn chưa có tài khoản", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          const Text("Đăng nhập để đăng tin và lưu phòng yêu thích", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 40),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF37DD63), minimumSize: const Size(double.infinity, 55)),
              child: const Text("Đăng nhập", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 15),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF37DD63), width: 2),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("Đăng ký tài khoản", style: TextStyle(color: Color(0xFF37DD63), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF37DD63),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: widget.isGuest
          ? const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
            ]
          : const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
              BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Quản lý"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Thông báo"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
            ],
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Tin đăng mới nhất", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {}, child: const Text("Xem tất cả >", style: TextStyle(color: Color(0xFF37DD63)))),
        ],
      ),
    );
  }
}