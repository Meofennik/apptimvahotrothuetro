import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterService {
  static Future<Map<String, dynamic>> registerUser({
    required String fullname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đăng ký thành công'};
      } else {
        return {'success': false, 'message': 'Đăng ký thất bại. Email có thể đã tồn tại!'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối Server: $e'};
    }
  }
}