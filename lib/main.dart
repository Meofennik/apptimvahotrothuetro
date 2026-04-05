import 'package:flutter/material.dart';
import 'Screens/WelcomeScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/RegisterScreen.dart';
import 'Screens/HomePageScreen.dart'; // Import cái file có giao diện Grid của bạn

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
        primaryColor: const Color(0xFF37DD63), 
      ),
      home: const WelcomeScreen(), 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePageScreen(), // Gọi đúng cái file đã tách
      },
    );
  }
}