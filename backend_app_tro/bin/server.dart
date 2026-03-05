import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// 1. Hàm dùng chung để kết nối Database apphotrotimvathuetro
Future<MySQLConnection> getDbConnection() async {
  final conn = await MySQLConnection.createConnection(
    host: "127.0.0.1", 
    port: 3306,
    userName: "root", // Kiểm tra lại nếu bạn có đặt mật khẩu trong MySQL Workbench
    password: "", 
    databaseName: "apphotrotimvathuetro", 
  );
  await conn.connect();
  return conn;
}

void main() async {
  final router = Router();

  // Route mặc định: Kiểm tra Server sống
  router.get('/', (Request request) {
    return Response.ok('Server App Tim Tro Gia Lam dang hoat dong!');
  });

  // API 1: Lay danh sach tro (Kem 1 anh dai dien cho thanh vien 2)
  router.get('/api/rooms', (Request request) async {
    final conn = await getDbConnection();
    // Truy vấn lấy thông tin phòng và 1 ảnh đầu tiên từ bảng room_images
    final result = await conn.execute("""
      SELECT r.*, 
      (SELECT image_url FROM room_images WHERE room_id = r.id LIMIT 1) as thumbnail 
      FROM rooms r ORDER BY r.created_at DESC
    """);
    
    final rooms = result.rows.map((row) => row.assoc()).toList();
    await conn.close();
    return Response.ok(jsonEncode(rooms), headers: {'Content-Type': 'application/json'});
  });

  // API 2: Lay chi tiet tat ca anh cua 1 phong (Cho man hinh Chi tiet)
  router.get('/api/rooms/<id>/images', (Request request, String id) async {
    final conn = await getDbConnection();
    final result = await conn.execute(
      "SELECT image_url FROM room_images WHERE room_id = :id", 
      {"id": id}
    );
    
    final images = result.rows.map((row) => row.assoc()['image_url']).toList();
    await conn.close();
    return Response.ok(jsonEncode(images), headers: {'Content-Type': 'application/json'});
  });

  // API 3: Dang tin tro moi (Nhan Link tu Cloudinary va luu vao MySQL)
  router.post('/api/add-room', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final conn = await getDbConnection();

    // Bước 1: Luu thong tin chu vao bang rooms
    final roomResult = await conn.execute(
      "INSERT INTO rooms (user_id, title, price, address, description) "
      "VALUES (:uid, :t, :p, :a, :d)",
      {
        'uid': payload['user_id'],
        't': payload['title'],
        'p': payload['price'],
        'a': payload['address'],
        'd': payload['description'],
      },
    );
    final roomId = roomResult.lastInsertID;

    // Bước 2: Luu danh sach Link anh vao bang room_images
    if (payload['images'] != null && payload['images'] is List) {
      final List<dynamic> imgs = payload['images'];
      for (var url in imgs) {
        await conn.execute(
          "INSERT INTO room_images (room_id, image_url) VALUES (:rid, :url)",
          {'rid': roomId, 'url': url},
        );
      }
    }

    await conn.close();
    return Response.ok(
      jsonEncode({"message": "Dang tin thanh cong!", "room_id": roomId}),
      headers: {'Content-Type': 'application/json'}
    );
  });

  // API 4: Dang ky tai khoan moi
  router.post('/api/register', (Request request) async {
    final payload = jsonDecode(await request.readAsString());

    // Nếu không có avatar, dùng link mặc định giống Facebook
    String avatarUrl = payload['avatar'] ?? "https://www.gstatic.com/images/branding/product/2x/avatar_anonymous_96x96dp.png";

    final conn = await getDbConnection();
    await conn.execute(
      "INSERT INTO users (fullname, email, password, avatar) VALUES (:f, :e, :p, :a)",
      {
        "f": payload['fullname'],
        "e": payload['email'],
        "p": payload['password'],
        "a": avatarUrl
      }
    );
    await conn.close();
    return Response.ok(jsonEncode({"message": "Dang ky thanh cong!"}));
  });

  // 3. Khoi chay server tai cong 8080
  final server = await shelf_io.serve(router, '0.0.0.0', 8080);
  print('Backend dang chay tai http://${server.address.host}:${server.port}');
}