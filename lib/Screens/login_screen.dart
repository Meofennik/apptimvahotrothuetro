import 'package:flutter/material.dart';
import 'package:apptimvahotrothuetro/Screens/register_screen.dart';
import 'package:apptimvahotrothuetro/Screens/homepage_screen.dart';
import '../services/login_services.dart'; // Import service mới tạo
import '../services/auth_service.dart'; // Import AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isLoading = false; // Biến khóa nút chống treo
  final Color primaryGreen = const Color(0xFF32D74B);

  // Xử lý đăng nhập gọi qua Service
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ email và mật khẩu!");
      return;
    }

    setState(() { _isLoading = true; });

    // Gọi API từ thư mục services
    final result = await LoginService.loginUser(
      email: _emailController.text,
      password: _passController.text,
    );

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (result['success'] == true) {
      print("✅ Login success: ${result}");
      final userId = result['user_id'];
      print("🔑 User ID: $userId");
      
      if (userId == null || userId == 0) {
        _showErrorDialog("Lỗi: Không thể lấy ID người dùng!");
        return;
      }
      
      // Lưu dữ liệu người dùng vào shared_preferences
      await AuthService.saveLoginData(
        userId: userId,
        email: _emailController.text,
        token: result['token'],
      );
      
      print("💾 Saved to SharedPreferences");
      
      // Đăng nhập thành công -> Vào HomePage với quyền User (4 tabs)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageScreen(isGuest: false)),
        );
      }
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thông báo"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))
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
              Text('Tìm và thuê trọ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryGreen)),
              const SizedBox(height: 10),
              const Text('Đăng nhập', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text('Chào mừng bạn quay trở lại', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),

              _buildTextField('Email hoặc Số điện thoại', 'Nhập email/SĐT', _emailController),
              const SizedBox(height: 20),
              _buildTextField('Mật khẩu', 'Nhập mật khẩu', _passController, obscureText: true),
              
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Quên mật khẩu?', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Đăng nhập được bảo vệ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: Text('Đăng ký ngay', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}