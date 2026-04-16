import 'package:flutter/material.dart';
import './welcome_screen.dart';
import './homepage_screen.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF32D74B),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User đã đăng nhập trước đó
          return const HomePageScreen(isGuest: false);
        } else {
          // Lần đầu hoặc chưa đăng nhập
          return const WelcomeScreen();
        }
      },
    );
  }
}
