import 'package:flutter/material.dart';
import 'package:apptimvahotrothuetro/Screens/login_screen.dart';
import '../services/register_services.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isLoading = false; 
  final Color primaryGreen = const Color(0xFF32D74B);

  // Hàm xử lý khi nút Đăng ký được nhấn
  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() { _isLoading = true; });

    // GỌI SERVICE TỪ THƯ MỤC SERVICES
    final result = await RegisterService.registerUser(
      fullname: _nameController.text,
      email: _emailController.text,
      password: _passController.text,
    );

    if (!mounted) return;
    setState(() { _isLoading = false; });

    // Xử lý kết quả trả về từ Service
    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Chúc mừng!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: const Text("Bạn đã đăng ký tài khoản thành công. Bây giờ hãy đăng nhập nhé!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Đồng ý (OK)", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
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
              const Text('Tìm và thuê trọ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF32D74B))),
              const SizedBox(height: 10),
              const Text('Tạo tài khoản', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
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
                  onPressed: _isLoading ? null : _handleRegister, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng ký', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Đăng nhập', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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