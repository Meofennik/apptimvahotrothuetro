
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // Lấy thông tin Profile
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/user/$userId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : {};
  }

  // Lấy danh sách thông báo
  static Future<List<dynamic>> getNotifications(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/notifications/$userId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }
}