import 'package:flutter/material.dart';
import 'models/room_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('RoomCard Demo')),
        body: Center(
          child: RoomCard(
            imageUrl: 'https://via.placeholder.com/150',
            price: '3,500,000 ₫',
            // address omitted → defaults to 'Gia Lâm'
          ),
        ),
      ),
    );
  }
}