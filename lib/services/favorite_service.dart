import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteService {
  // Thêm tin vào yêu thích
  static Future<Map<String, dynamic>> addFavorite({
    required int userId,
    required int roomId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/add_favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'room_id': roomId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã thêm vào yêu thích'};
      } else {
        return {'success': false, 'message': 'Thêm yêu thích thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Xóa tin khỏi yêu thích
  static Future<Map<String, dynamic>> removeFavorite({
    required int userId,
    required int roomId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/remove_favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'room_id': roomId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã xóa khỏi yêu thích'};
      } else {
        return {'success': false, 'message': 'Xóa yêu thích thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Lấy danh sách yêu thích của user
  static Future<Map<String, dynamic>> getFavorites(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/favorites/$userId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'favorites': data['favorites'] ?? []};
      } else {
        return {'success': false, 'favorites': []};
      }
    } catch (e) {
      print('Lỗi lấy yêu thích: $e');
      return {'success': false, 'favorites': []};
    }
  }

  // Kiểm tra tin có trong yêu thích không
  static Future<bool> isFavorited({
    required int userId,
    required int roomId,
  }) async {
    try {
      final result = await getFavorites(userId);
      if (result['success']) {
        final favorites = result['favorites'] as List;
        return favorites.any((fav) => fav['room_id'] == roomId);
      }
    } catch (e) {
      print('Lỗi kiểm tra yêu thích: $e');
    }
    return false;
  }
}
