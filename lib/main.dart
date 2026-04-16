import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Screens/auth_wrapper.dart';
import 'Screens/login_screen.dart';
import 'Screens/register_screen.dart';
import 'Screens/homepage_screen.dart';
import 'models/room_model.dart';
import 'widgets/room_card.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tìm và thuê trọ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF37DD63), 
      ),
      home: const AuthWrapper(), 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePageScreen(isGuest: false),
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
      body: FutureBuilder<int?>(
        future: AuthService.getUserId(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final userId = userSnapshot.data ?? 0;
          
          return FutureBuilder<List<RoomModel>>(
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
                      roomId: room.id,
                      userId: userId,
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
          );
        },
      ),
    );
  }

}