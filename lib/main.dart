import 'package:flutter/material.dart';
import 'Screens/welcome_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/register_screen.dart';
import 'Screens/homepage_screen.dart'; 

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
        '/home': (context) => const HomePageScreen(),
      },
    );
  }
}