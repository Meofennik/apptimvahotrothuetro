import 'package:flutter/material.dart';
import 'package:apptimvahotrothuetro/Screens/login_screen.dart';
import 'package:apptimvahotrothuetro/Screens/register_screen.dart';
import 'package:apptimvahotrothuetro/Screens/homepage_screen.dart';
import 'package:apptimvahotrothuetro/services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max, 
              children: [
                // Tiêu đề chính
                const Text(
                  'Tìm và thuê trọ',
                  style: TextStyle(
                    color: Color(0xFF32D74B), 
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tìm và thuê dễ dàng',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                
                const SizedBox(height: 50),
                // Logo
                Image.asset(
                  'assets/logofita.png',
                  height: 160,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 100),
                ),
                const SizedBox(height: 50),

                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32D74B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Nút Đăng ký
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF32D74B), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng ký tài khoản',
                      style: TextStyle(color: Color(0xFF32D74B), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Tiếp tục với tư cách khách
                TextButton(
                  onPressed: () async {
                    // Thiết lập guest mode và lưu vào shared_preferences
                    await AuthService.setGuestMode();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePageScreen(isGuest: true),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Tiếp tục với tư cách khách',
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}