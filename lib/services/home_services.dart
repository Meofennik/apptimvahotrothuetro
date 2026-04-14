import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeService {
  // Hàm lấy danh sách phòng trọ từ Backend
  static Future<List<dynamic>> fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/rooms')
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về danh sách phòng
      } else {
        print("Lỗi Server: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối HomeService: $e");
      return [];
    }
  }
}