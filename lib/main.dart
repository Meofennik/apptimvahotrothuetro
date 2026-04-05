import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/room_model.dart';
import 'widgets/room_card.dart';
// Import các màn hình mới của bạn
import 'Screens/WelcomeScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/RegisterScreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tìm và thuê trọ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Màu xanh chủ đạo từ thiết kế của bạn
        primaryColor: const Color(0xFF32D74B), 
      ),
      // Thay đổi điểm bắt đầu ứng dụng thành WelcomeScreen
      home: const WelcomeScreen(), 
      
      // Định nghĩa routes để dễ dàng quản lý điều hướng
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<RoomModel>> fetchRooms() async {
    // Lưu ý: 10.0.2.2 dành cho máy ảo Android kết nối về localhost máy Leader 
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/rooms'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => RoomModel.fromJson(data)).toList();
    } else {
      throw Exception('Không thể tải danh sách trọ. Vui lòng kiểm tra Server!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Trọ'),
        backgroundColor: const Color(0xFF32D74B), // Màu xanh thống nhất thiết kế
        centerTitle: true,
      ),
      body: FutureBuilder<List<RoomModel>>(
        future: fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final room = snapshot.data![index];
                return RoomCard(
                  imageUrl: room.imageUrl,
                  price: room.price,
                  address: room.address, 
                  title: room.title,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          return const Center(child: Text("Không có dữ liệu"));
        },
      ),
    );
  }
}