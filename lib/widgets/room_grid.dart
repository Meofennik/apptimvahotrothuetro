import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';
import 'room_card.dart';

class RoomGrid extends StatelessWidget {
  const RoomGrid({super.key});

  // Hàm lấy dữ liệu giữ nguyên logic của bạn
  Future<List<RoomModel>> fetchRooms() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/rooms'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => RoomModel.fromJson(data)).toList();
    } else {
      throw Exception('Lỗi kết nối Server!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: fetchRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final room = snapshot.data![index];
              return RoomCard(
                title: room.title,
                imageUrl: room.imageUrl,
                price: room.price,
                address: room.address,
              );
            },
          );
        }
        return const Center(child: Text("Đang tải dữ liệu..."));
      },
    );
  }
}