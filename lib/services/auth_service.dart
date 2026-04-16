import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isGuestKey = 'is_guest';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _tokenKey = 'auth_token';

  // Lưu trạng thái đăng nhập khi user đăng nhập thành công
  static Future<void> saveLoginData({
    required int userId,
    required String email,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_emailKey, email);
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    await prefs.setBool(_isGuestKey, false);
  }

  // Thiết lập trạng thái guest
  static Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, true);
  }

  // Kiểm tra xem user có phải guest không
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? true; // Mặc định là guest
  }

  // Lấy userId hiện tại
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Lấy email hiện tại
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Lấy auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Logout - xóa tất cả dữ liệu và thiết lập lại guest mode
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isGuestKey, true);
  }

  // Kiểm tra xem user đã đăng nhập hay chưa
  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null;
  }
}
