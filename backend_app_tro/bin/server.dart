import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// 1. Kết nối Database
Future<MySQLConnection> getDbConnection() async {
  final conn = await MySQLConnection.createConnection(
    host: "127.0.0.1",
    port: 3306,
    userName: "root",
    password: "",
    databaseName: "apphotrotimvathuetro",
    secure: false,
  );
  await conn.connect();
  return conn;
}

void main() async {
  final router = Router();

  // Route kiểm tra Server
router.post('/api/register', (Request request) async {
  try {
    final payload = jsonDecode(await request.readAsString());
    final conn = await getDbConnection();
    
    // In ra để kiểm tra xem Server đã nhận được dữ liệu chưa
    print("Nhan du lieu dang ky: ${payload['email']}");

    await conn.execute(
      "INSERT INTO users (fullname, email, password, avatar) VALUES (:f, :e, :p, :a)",
      {
        "f": payload['fullname'],
        "e": payload['email'],
        "p": payload['password'],
        "a": payload['avatar'] ?? "",
      },
    );
    await conn.close();
    return Response(200, body: jsonEncode({"message": "OK"}), headers: {'Content-Type': 'application/json'});
  } catch (e) {
    print("Loi MySQL thuc su: $e"); // XEM DÒNG NÀY Ở TERMINAL
    return Response.internalServerError(body: jsonEncode({"error": e.toString()}));
  }
});

  // API Đăng nhập [Khớp với LoginScreen]
  router.post('/api/login', (Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      final result = await conn.execute(
        "SELECT id, fullname, email, avatar FROM users WHERE email = :e AND password = :p",
        {"e": payload['email'], "p": payload['password']},
      );
      
      await conn.close();
      if (result.rows.isNotEmpty) {
        return Response.ok(jsonEncode({
          "status": "success", 
          "user": result.rows.first.assoc()
        }), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.forbidden(jsonEncode({"status": "error", "message": "Sai tai khoan hoac mat khau"}));
      }
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({"error": e.toString()}));
    }
  });

  // API Lấy danh sách trọ (Có ảnh thumbnail)
  router.get('/api/rooms', (Request request) async {
    final conn = await getDbConnection();
    final result = await conn.execute("""
      SELECT r.*, 
      (SELECT image_url FROM room_images WHERE room_id = r.id LIMIT 1) as thumbnail 
      FROM rooms r ORDER BY r.created_at DESC
    """);
    
    final rooms = result.rows.map((row) => row.assoc()).toList();
    await conn.close();
    return Response.ok(jsonEncode(rooms), headers: {'Content-Type': 'application/json'});
  });

  // API Thêm phòng trọ mới (Nhận link từ Cloudinary)
  router.post('/api/add-room', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final conn = await getDbConnection();

    // Bước 1: Lưu thông tin vào bảng rooms
    final roomResult = await conn.execute(
      "INSERT INTO rooms (user_id, title, price, address, description) VALUES (:uid, :t, :p, :a, :d)",
      {
        'uid': payload['user_id'],
        't': payload['title'],
        'p': payload['price'],
        'a': payload['address'],
        'd': payload['description'],
      },
    );
    
    // Bước 2: Lưu danh sách ảnh
    if (payload['images'] != null && payload['images'] is List) {
      for (var url in payload['images']) {
        await conn.execute(
          "INSERT INTO room_images (room_id, image_url) VALUES (:rid, :url)",
          {'rid': roomResult.lastInsertID, 'url': url},
        );
      }
    }

    await conn.close();
    return Response.ok(jsonEncode({"message": "Dang tin thanh cong!"}));
  });

  // Khởi chạy Server
  final server = await shelf_io.serve(router, '0.0.0.0', 8080);
  print('Backend dang chay tai http://${server.address.host}:${server.port}');
}