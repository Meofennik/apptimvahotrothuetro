import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';
  late Process p;

  setUp(() async {
    // Đảm bảo không có bản server nào đang chạy chiếm cổng 8080 trước khi test
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port}, // Truyền biến môi trường nếu cần
    );

    // Chờ Server khởi động và in log ra để kiểm tra
    // Tăng lên 3-5 giây nếu máy ASUS G14 đang chạy nhiều tác vụ
    await Future.delayed(Duration(seconds: 3)); 
  });

  tearDown(() {
    p.kill(); // Đóng server sau khi test xong để giải phóng cổng
  });

  // TEST ĐĂNG KÝ THÀNH CÔNG
  test('POST /api/register - Successful registration', () async {
    try {
      final response = await http.post(
        Uri.parse('$host/api/register'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'fullname': 'Test User',
          'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com', // Tránh trùng lặp email trong DB
          'password': 'password123'
        }),
      );
      
      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['message'], 'OK');
    } catch (e) {
      fail("Không thể kết nối tới Server Test: $e");
    }
  });

  // TEST LỖI BASE64 (Cho API Add Room Pro)
  test('POST /api/add_room_pro - Invalid base64 image', () async {
    final response = await http.post(
      Uri.parse('$host/api/add_room_pro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image_base64': 'invalid_base64_data_@@@'
      }),
    );
    
    // Server của bạn trả về 500 khi có lỗi try-catch
    expect(response.statusCode, 500);
    final data = jsonDecode(response.body);
    expect(data.containsKey('error'), true);
  });
}