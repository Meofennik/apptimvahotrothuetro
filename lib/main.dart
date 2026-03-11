import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/room_model.dart';
import 'widgets/room_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Hàm lấy dữ liệu từ Server Dart
  Future<List<RoomModel>> fetchRooms() async {
    // Sử dụng IP 10.0.2.2 để máy ảo Android hiểu là localhost của máy tính
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
        title: const Text('Tìm Trọ Gia Lâm'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: FutureBuilder<List<RoomModel>>(
        future: fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final room = snapshot.data![index];
                return RoomCard(
                  imageUrl: room.imageUrl,
                  price: room.price,
                  address: room.address, title: '',
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          // Hiển thị vòng xoay chờ đợi dữ liệu
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}