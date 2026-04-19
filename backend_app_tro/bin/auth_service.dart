import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Hàm LƯU ID khi người dùng Đăng nhập thành công 
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
  }

  // Hàm LẤY ID ra để dùng (Chính là hàm bạn đang gọi ở nút Thả tim)
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); 
    // Trả về số ID (VD: 1, 2, 5...) hoặc trả về null nếu chưa đăng nhập
  }

  // Hàm XÓA ID khi người dùng Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}