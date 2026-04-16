import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📥 Backend response: $data");
        // Trả về đầy đủ dữ liệu user
        return {
          'success': true,
          'user_id': data['user']['id'] ?? 0,
          'email': data['user']['email'] ?? email,
          'fullname': data['user']['fullname'] ?? '',
          'token': data['token'],
          'message': 'Đăng nhập thành công!'
        };
      } else {
        return {'success': false, 'message': 'Email hoặc mật khẩu không chính xác!'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối Server: $e'};
    }
  }
}