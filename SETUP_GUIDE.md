# 📱 Hướng Dẫn Cấu Hình Guest/Login System

## 📋 Các Thay Đổi Đã Thực Hiện

### 1. ✅ Tạo AuthService
- **File**: `lib/services/auth_service.dart`
- **Chức năng**: Quản lý trạng thái đăng nhập/guest sử dụng `shared_preferences`
- **Các hàm chính**:
  - `setGuestMode()` - Thiết lập chế độ khách
  - `saveLoginData()` - Lưu dữ liệu người dùng khi đăng nhập
  - `isGuest()` - Kiểm tra xem user có phải khách hay không
  - `logout()` - Đăng xuất và xóa dữ liệu

### 2. ✅ Tạo AuthWrapper
- **File**: `lib/Screens/auth_wrapper.dart`
- **Chức năng**: Kiểm tra trạng thái user khi app khởi động
- Nếu user đã đăng nhập trước → vào HomePage (không phải guest)
- Nếu chưa đăng nhập → vào WelcomeScreen

### 3. ✅ Cập Nhật main.dart
- Sử dụng `ConfigApp` thay vì `WelcomeScreen` làm home
- Import `AuthService` và `AuthWrapper`

### 4. ✅ Cập Nhật WelcomeScreen
- Nút "Tiếp tục với tư cách khách" giờ sẽ:
  - Gọi `AuthService.setGuestMode()` để lưu trạng thái
  - Chuyển đến `HomePageScreen(isGuest: true)`

### 5. ✅ Cập Nhật LoginScreen
- Khi đăng nhập thành công, gọi `AuthService.saveLoginData()` để lưu dữ liệu

### 6. ✅ Cập Nhật HomePageScreen
- Hiển thị hai phiên bản khác nhau:
  - **Guest mode** (2 tabs): Trang chủ + Tài khoản (yêu cầu đăng nhập)
  - **User mode** (4 tabs): Trang chủ + Quản lý + Thông báo + Cá nhân

### 7. ✅ Cập Nhật ProfileScreen
- Thêm nút **ĐĂNG XUẤT** màu đỏ
- Khi ấn logout:
  - Xóa dữ liệu người dùng
  - Quay lại WelcomeScreen

### 8. ✅ Cập Nhật PostRoomScreen
- Check xem user đã đăng nhập hay chưa
- Nếu chưa đăng nhập → chuyển đến LoginScreen
- Lấy `user_id` từ `AuthService` thay vì hardcode

### 9. ✅ Thêm shared_preferences vào pubspec.yaml
- Dependency: `shared_preferences: ^2.2.2`

---

## 🚀 Cách Sử Dụng

### Bước 1: Install Dependencies
```bash
flutter pub get
```

### Bước 2: Flow Người Dùng

#### **Lần Đầu Mở App**
```
WelcomeScreen
  ├─ "Đăng nhập" → LoginScreen
  ├─ "Đăng ký" → RegisterScreen
  └─ "Tiếp tục với tư cách khách" → HomePageScreen (isGuest: true)
```

#### **Mode Guest**
- Chỉ nhìn thấy 2 tabs: **Trang chủ** và **Tài khoản**
- Tab "Tài khoản" hiển thị:
  - Dòng chữ: "Bạn chưa có tài khoản"
  - 2 nút: "Đăng nhập" và "Đăng ký tài khoản"
- Không thể đăng tin hoặc xem thông báo cá nhân

#### **Mode User (Đã Đăng Nhập)**
- Nhìn thấy 4 tabs: **Trang chủ**, **Quản lý**, **Thông báo**, **Cá nhân**
- Tab "Cá nhân" hiển thị:
  - Thông tin người dùng
  - Nút "ĐĂNG TIN MỚI"
  - Nút "ĐĂNG XUẤT" (đỏ)

---

## 💾 Dữ Liệu Lưu Trữ

### SharedPreferences Keys
```dart
_isGuestKey = 'is_guest'          // Bool: true/false
_userIdKey = 'user_id'            // Int: ID người dùng
_emailKey = 'user_email'          // String: Email
_tokenKey = 'auth_token'          // String: Auth token (tùy chọn)
```

---

## 🔐 Security Notes

⚠️ **Để cải thiện bảo mật**:
1. Không lưu trữ token/password trong `shared_preferences` khi production
2. Sử dụng secure storage như `flutter_secure_storage` cho tokens
3. Implement JWT refresh token mechanism
4. Validate user session khi app mở lại

---

## 📝 Ví Dụ Sử Dụng AuthService

```dart
// Kiểm tra xem user là guest hay không
bool isGuest = await AuthService.isGuest();

// Lấy thông tin user
int? userId = await AuthService.getUserId();
String? email = await AuthService.getUserEmail();

// Lưu dữ liệu đăng nhập
await AuthService.saveLoginData(
  userId: 123,
  email: 'user@example.com',
  token: 'jwt_token_here',
);

// Logout
await AuthService.logout();
```

---

## 🧪 Testing

### Test Guest Flow
1. Mở app
2. Ấn "Tiếp tục với tư cách khách"
3. Verify: Chỉ thấy 2 tabs
4. Ấn tab "Tài khoản" → Thấy form yêu cầu đăng nhập

### Test Login Flow
1. Mở app → Ấn "Đăng nhập"
2. Nhập email/password và đăng nhập
3. Verify: Chuyển sang HomePageScreen với 4 tabs

### Test Logout Flow
1. Đăng nhập thành công
2. Tab "Cá nhân" → Ấn "ĐĂNG XUẤT"
3. Verify: Quay lại WelcomeScreen

---

## 🐛 Troubleshooting

### Error: `MissingPluginException` với shared_preferences
**Giải pháp**:
```bash
flutter clean
flutter pub get
flutter run
```

### Sau khi logout, vẫn hiển thị dữ liệu cũ
**Giải pháp**: Restart app hoặc gọi `AuthService.logout()` rồi rebuild UI

---

## 📞 Liên Hệ & Support
- Mọi câu hỏi về flow auth, vui lòng tham khảo AuthService
- Các file chính: `auth_wrapper.dart`, `auth_service.dart`, `homepage_screen.dart`
