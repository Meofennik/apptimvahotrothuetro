import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apptimvahotrothuetro/Screens/LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Khai báo các Controller để lấy dữ liệu từ TextField [Bài 7]
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final Color primaryGreen = const Color(0xFF32D74B);

  // 2. Hàm xử lý đăng ký kết nối Backend
  Future<void> registerUser() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) {
      _showDialog("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'fullname': _nameController.text,
          'email': _emailController.text,
          'password': _passController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Đăng ký thành công -> Quay lại Login
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showDialog("Đăng ký thất bại. Email có thể đã tồn tại!");
      }
    } catch (e) {
      _showDialog("Lỗi kết nối Server: $e");
    }
  }

  Future<void> login() async {
  final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'fullname': _nameController.text,
          'email': _emailController.text,
          'password': _passController.text,
        }),

  ); // Đợi phản hồi từ server máy Leader

  if (!mounted) return; // Nếu màn hình đã đóng thì dừng lại ngay

  if (response.statusCode == 200) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    showDialog(
      context: context, // Bây giờ context đã an toàn để sử dụng
      builder: (ctx) => AlertDialog(
        title: const Text("Thông báo"),
        content: const Text("Đăng ký thất bại. Vui lòng thử lại!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }
}

  // Hàm hiển thị thông báo 
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông báo"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tìm và thuê trọ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF32D74B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tạo tài khoản',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Truyền Controller vào hàm buildTextField
              _buildTextField('Họ và tên', 'Nhập họ tên', _nameController),
              const SizedBox(height: 20),
              _buildTextField('Email', 'Nhập email của bạn', _emailController),
              const SizedBox(height: 20),
              _buildTextField('Mật khẩu', 'Tối thiểu 6 ký tự', _passController, obscureText: true),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: registerUser, // Gọi hàm xử lý đã viết ở trên
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cập nhật hàm build để nhận Controller
  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Gán controller vào đây
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}