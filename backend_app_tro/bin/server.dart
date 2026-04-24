import 'dart:convert';
import 'dart:io';
import 'package:cloudinary/cloudinary.dart' as cloud;
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:dotenv/dotenv.dart'; // Đã sửa lại import chuẩn, bỏ các lệnh show rườm rà

final _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

// Khởi tạo Cloudinary
late final cloud.Cloudinary _cloudinary;

Future<MySQLConnection> getDbConnection() async {
  print("Đang kết nối MySQL (XAMPP)...");
  try {
    final conn = await MySQLConnection.createConnection(
      host: "127.0.0.1",
      port: 3306,
      userName: "theanh",
      password: "123456",
      databaseName: "apphotrotimvathuetro",
      secure: false,
    );
  
    await conn.connect().timeout(const Duration(seconds: 5)); 
    
    print("Kết nối MySQL THÀNH CÔNG!");
    return conn;
  } catch (e) {
    print("LỖI KẾT NỐI MYSQL: $e");
    rethrow;
  }
}

void main() async {
  // 1. KHỞI TẠO ĐỐI TƯỢNG DOTENV CHUẨN XÁC
  final dotEnv = DotEnv();

  try {
    final envFile = File('cloudinary.env');

    if (!envFile.existsSync()) {
      print("Lỗi: Không tìm thấy file cloudinary.env");
      exit(1);
    }

    // Load đúng file thông qua đối tượng dotEnv
    dotEnv.load(['cloudinary.env']);
    print("Loaded cloudinary.env successfully");
  } catch (e) {
    print("Error loading cloudinary.env: $e");
    exit(1);
  }

  // 2. TRUY XUẤT BIẾN
  final cloudName = dotEnv['CLOUDINARY_CLOUD_NAME'];
  final apiKey = dotEnv['CLOUDINARY_API_KEY'];
  final apiSecret = dotEnv['CLOUDINARY_API_SECRET'];

  if (cloudName == null || cloudName.isEmpty) {
    print("Error: CLOUDINARY_CLOUD_NAME not found in env file");
    exit(1);
  }

  _cloudinary = cloud.Cloudinary.signedConfig(
    apiKey: apiKey ?? "",
    apiSecret: apiSecret ?? "",
    cloudName: cloudName,
  );

  print("Cloudinary ready - Cloud: $cloudName");

  final router = Router();

  // API Đăng ký
  router.post('/api/register', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      await conn.execute(
        "INSERT INTO users (fullname, email, password) VALUES (:f, :e, :p)",
        {
          "f": payload['fullname'],
          "e": payload['email'],
          "p": payload['password']
        },
      );
      await conn.close();
      return shelf.Response.ok(jsonEncode({"message": "OK"}),
          headers: _jsonHeaders);
    } catch (e) {
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}), headers: _jsonHeaders);
    }
  });

  // API Đăng nhập
  router.post('/api/login', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();

      final results = await conn.execute(
        "SELECT id, fullname, email FROM users WHERE email = :e AND password = :p",
        {"e": payload['email'], "p": payload['password']},
      );

      await conn.close();

      if (results.rows.isEmpty) {
        return shelf.Response(401,
            body: jsonEncode({
              "success": false,
              "message": "Email hoặc mật khẩu không chính xác"
            }),
            headers: _jsonHeaders);
      }

      final userRow = results.rows.first;
      
      // assoc là property (không phải method)
      final userData = userRow.assoc();

      print("Login successful - User: ${userData['email']}");
      return shelf.Response.ok(
        jsonEncode({
          "success": true,
          "user": {
            "id": int.tryParse(userData["id"].toString()) ?? 0,
            "fullname": userData["fullname"] ?? "",
            "email": userData["email"] ?? ""
          }
        }),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Login error: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Lấy tất cả bài đăng
 router.get('/api/rooms', (shelf.Request request) async {
    try {
      final conn = await getDbConnection();
      
      // 1. Lấy user_id từ URL xuống 
      final queryParams = request.url.queryParameters;
      final userIdStr = queryParams['user_id'];
      
      // Nếu khách chưa đăng nhập lướt app, mặc định gán userId = 0 (để không cái tim nào sáng lên)
      final userId = userIdStr != null ? int.tryParse(userIdStr) : 0; 
      final results = await conn.execute(
        """
        SELECT r.id, r.title, r.price, r.address, r.description,
               (SELECT image_url FROM room_images WHERE room_id = r.id LIMIT 1) AS cover_image,
               IF(f.id IS NOT NULL, 1, 0) AS is_favorited 
        FROM rooms r 
        LEFT JOIN favorites f ON r.id = f.room_id AND f.user_id = :uid 
        ORDER BY r.created_at DESC
        """,
        {"uid": userId} // Truyền ID user để SQL đối chiếu
      );

      final rooms = results.rows.map((row) {
        final assoc = row.assoc();
        return {
          "id": assoc['id'],
          "title": assoc['title'],
          "price": assoc['price'],
          "address": assoc['address'],
          "description": assoc['description'], 
          "image_url": assoc['cover_image'], 
          "is_favorited": assoc['is_favorited'], 
        };
      }).toList();
      
      await conn.close();
      print("Fetched ${rooms.length} rooms successfully");
      
      return shelf.Response.ok(
        jsonEncode(rooms),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching rooms: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Lấy thông tin user theo ID
  router.get('/api/user/<userId>', (shelf.Request request, String userId) async {
    try {
      final conn = await getDbConnection();
      final uid = int.parse(userId);
      
      final results = await conn.execute(
        "SELECT id, fullname, email FROM users WHERE id = :id",
        {"id": uid}
      );
      
      await conn.close();
      
      if (results.rows.isEmpty) {
        return shelf.Response(404,
            body: jsonEncode({"error": "User not found"}),
            headers: _jsonHeaders);
      }
      
      final userData = results.rows.first.assoc();
      
      print("Fetched user info for user $userId");
      return shelf.Response.ok(
        jsonEncode({
          "id": userData['id'],
          "fullname": userData['fullname'],
          "email": userData['email'],
          "avatar": "https://via.placeholder.com/150" // Placeholder avatar
        }),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching user info: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Lấy danh sách thông báo (placeholder)
  router.get('/api/notifications/<userId>', (shelf.Request request, String userId) async {
    try {
      print("Fetching notifications for user $userId");
      return shelf.Response.ok(
        jsonEncode([]), // Trả về danh sách rỗng cho giờ
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching notifications: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Đăng tin (rooms, room_images, amenities)
  router.post('/api/add_room', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      // Lấy danh sách link ảnh từ Cloudinary mà App gửi lên
      final List dynamicImages = payload['images'] ?? [];

      await conn.execute(
        "INSERT INTO rooms (user_id, title, price, address, description) "
        "VALUES (:uid, :t, :p, :a, :desc)",
        {
          "uid": payload['user_id'],
          "t": payload['title'],
          "p": payload['price'],
          "a": payload['address'],
          "desc": payload['description']
        },
      );
      
      // Lấy ID phòng vừa chèn
      final roomIdResult = await conn.execute("SELECT LAST_INSERT_ID() as id");
      final roomId = roomIdResult.rows.first.assoc()['id'];
      
      // BƯỚC 2: Lưu toàn bộ danh sách ảnh vào bảng room_images
      for (var imgUrl in dynamicImages) {
        await conn.execute(
          "INSERT INTO room_images (room_id, image_url) VALUES (:rid, :img)",
          {"rid": roomId, "img": imgUrl.toString()}
        );
      }
      
      // BƯỚC 3: Lưu tiện ích
      if (payload['amenities'] != null && payload['amenities'] is List) {
        for (var amenityName in payload['amenities']) {
          await conn.execute(
            "INSERT INTO amenities (room_id, name) VALUES (:rid, :name)",
            {"rid": roomId, "name": amenityName},
          );
        }
      }
      
      await conn.close();
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Đăng tin thành công!"}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Lỗi đăng tin: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });
  // API Xóa tin
  router.post('/api/delete_room', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      await conn.execute(
        "DELETE FROM rooms WHERE id = :id AND user_id = :uid",
        {"id": payload['room_id'], "uid": payload['user_id']},
      );
      
      await conn.close();
      print("Room deleted successfully - Room: ${payload['room_id']}");
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Xóa tin thành công!"}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error deleting room: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Lấy danh sách ảnh phụ của một phòng
  router.get('/api/room_images/<roomId>', (shelf.Request request, String roomId) async {
    try {
      final conn = await getDbConnection();
      final results = await conn.execute(
        "SELECT image_url FROM room_images WHERE room_id = :rid",
        {"rid": int.parse(roomId)}
      );
      
      List<String> images = results.rows.map((row) => row.assoc()['image_url'].toString()).toList();
      await conn.close();
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "images": images}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      return shelf.Response.internalServerError(body: jsonEncode({"error": e.toString()}), headers: _jsonHeaders);
    }
  });
  
  // API Lấy danh sách tiện nghi của phòng
  router.get('/api/amenities/<roomId>', (shelf.Request request, String roomId) async {
    try {
      final conn = await getDbConnection();
      
      final results = await conn.execute(
        "SELECT id, name FROM amenities WHERE room_id = :rid",
        {"rid": int.parse(roomId)}
      );
      
      final amenities = results.rows.map((row) {
        final assoc = row.assoc();
        return {"id": assoc['id'], "name": assoc['name']};
      }).toList();
      
      await conn.close();
      return shelf.Response.ok(
        jsonEncode({"success": true, "amenities": amenities}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching amenities: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Cập nhật tiện nghi cho phòng
  router.post('/api/update_amenities', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      final roomId = payload['room_id'];
      final amenitiesList = payload['amenities'] ?? [];
      
      // Delete existing amenities
      await conn.execute(
        "DELETE FROM amenities WHERE room_id = :rid",
        {"rid": roomId},
      );
      
      // Insert new amenities
      for (var amenity in amenitiesList) {
        await conn.execute(
          "INSERT INTO amenities (room_id, name) VALUES (:rid, :name)",
          {"rid": roomId, "name": amenity},
        );
      }
      
      await conn.close();
      print("Amenities updated successfully for room $roomId");
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Cập nhật tiện nghi thành công!"}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error updating amenities: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Thêm vào yêu thích
  router.post('/api/add_favorite', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      await conn.execute(
        "INSERT INTO favorites (user_id, room_id) VALUES (:uid, :rid)",
        {"uid": payload['user_id'], "rid": payload['room_id']},
      );
      
      await conn.close();
      print("Favorite added successfully");
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Đã thêm vào yêu thích"}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error adding favorite: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Xóa khỏi yêu thích
  router.post('/api/remove_favorite', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      await conn.execute(
        "DELETE FROM favorites WHERE user_id = :uid AND room_id = :rid",
        {"uid": payload['user_id'], "rid": payload['room_id']},
      );
      
      await conn.close();
      print("Favorite removed successfully");
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Đã xóa khỏi yêu thích"}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error removing favorite: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Lấy danh sách yêu thích
  router.get('/api/favorites/<userId>', (shelf.Request request, String userId) async {
    try {
      final id = int.parse(userId);
      final conn = await getDbConnection();
      
      final results = await conn.execute(
        """
        SELECT r.id, r.title, r.price, r.address, r.description,
               (SELECT image_url FROM room_images WHERE room_id = r.id LIMIT 1) AS cover_image
        FROM rooms r 
        JOIN favorites f ON r.id = f.room_id 
        WHERE f.user_id = :uid
        """,
        {"uid": id},
      );
      
      await conn.close();
      
      final favorites = results.rows.map((row) {
        final data = row.assoc();
        return {
          "id": data["id"],
          "title": data["title"],
          "price": data["price"],
          "address": data["address"],
          "image_url": data["cover_image"],
          "room_id": data["id"]
        };
      }).toList();
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "favorites": favorites}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching favorites: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  router.post('/api/add_room_pro', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final imageBytes = base64Decode(payload['image_base64']);

      final response = await _cloudinary.upload(
        fileBytes: imageBytes,
        fileName: 'room_${DateTime.now().millisecondsSinceEpoch}.jpg',
        folder: "room_images",
        resourceType: cloud.CloudinaryResourceType.image,
      );

      return shelf.Response.ok(jsonEncode({"imageUrl": response.secureUrl}),
          headers: _jsonHeaders);
    } catch (e) {
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}), headers: _jsonHeaders);
    }
  });

  // API Thả tim / Bỏ tim phòng trọ
  router.post('/api/toggle_favorite', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final userId = payload['user_id'];
      final roomId = payload['room_id'];

      final conn = await getDbConnection();

      // 1. Kiểm tra xem user này đã thả tim phòng này chưa
      final check = await conn.execute(
        "SELECT id FROM favorites WHERE user_id = :uid AND room_id = :rid",
        {"uid": userId, "rid": roomId},
      );

      bool isFavorited = false;

      if (check.rows.isNotEmpty) {
        // 2. Nếu đã có tim -> Xóa đi (Bỏ yêu thích)
        await conn.execute(
          "DELETE FROM favorites WHERE user_id = :uid AND room_id = :rid",
          {"uid": userId, "rid": roomId},
        );
        isFavorited = false;
      } else {
        // 3. Nếu chưa có tim -> Thêm mới (Yêu thích)
        await conn.execute(
          "INSERT INTO favorites (user_id, room_id) VALUES (:uid, :rid)",
          {"uid": userId, "rid": roomId},
        );
        isFavorited = true;
      }

      await conn.close();

      return shelf.Response.ok(
        jsonEncode({
          "success": true,
          "is_favorited": isFavorited,
          "message": isFavorited ? "Đã thêm vào yêu thích" : "Đã bỏ yêu thích"
        }),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Lỗi toggle_favorite: $e");
      return shelf.Response.internalServerError(
        body: jsonEncode({"success": false, "error": e.toString()}),
        headers: _jsonHeaders,
      );
    }
  });

  // API Lấy danh sách phòng của user (Quản lý tin)
  router.get('/api/user_rooms/<userId>', (shelf.Request request, String userId) async {
    try {
      final conn = await getDbConnection();
      final uid = int.parse(userId);
      
      final results = await conn.execute(
        """
        SELECT r.id, r.title, r.price, r.address, r.description, r.created_at,
               (SELECT image_url FROM room_images WHERE room_id = r.id LIMIT 1) AS cover_image
        FROM rooms r 
        WHERE r.user_id = :uid 
        ORDER BY r.created_at DESC
        """,
        {"uid": uid}
      );
      
      final rooms = results.rows.map((row) {
        final assoc = row.assoc();
        return {
          "id": assoc['id'],
          "title": assoc['title'],
          "price": assoc['price'],
          "address": assoc['address'],
          "description": assoc['description'],
          "image_url": assoc['cover_image'],
          "created_at": assoc['created_at']
        };
      }).toList();
      
      await conn.close();
      print("Fetched ${rooms.length} user rooms for user $uid");
      
      return shelf.Response.ok(
        jsonEncode(rooms),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error fetching user rooms: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  // API Cập nhật thông tin phòng
  router.post('/api/update_room', (shelf.Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      final conn = await getDbConnection();
      
      final roomId = payload['room_id'];
      final userId = payload['user_id'];
      final title = payload['title'];
      final price = payload['price'];
      final address = payload['address'];
      final description = payload['description'];
      
      // Verify ownership
      final checkResults = await conn.execute(
        "SELECT user_id FROM rooms WHERE id = :id",
        {"id": roomId}
      );
      
      if (checkResults.rows.isEmpty) {
        await conn.close();
        return shelf.Response(404,
            body: jsonEncode({"success": false, "message": "Room not found"}),
            headers: _jsonHeaders);
      }
      
      final ownerRow = checkResults.rows.first.assoc();
      final ownerId = ownerRow['user_id'];
      
      if (ownerId.toString() != userId.toString()) {
        await conn.close();
        return shelf.Response(403,
            body: jsonEncode({"success": false, "message": "Unauthorized"}),
            headers: _jsonHeaders);
      }
      
      // Update room
      await conn.execute(
        "UPDATE rooms SET title = :t, price = :p, address = :a, description = :d WHERE id = :id",
        {
          "t": title,
          "p": price,
          "a": address,
          "d": description,
          "id": roomId
        }
      );
      
      await conn.close();
      print("Room updated successfully - Room ID: $roomId");
      
      return shelf.Response.ok(
        jsonEncode({"success": true, "message": "Cập nhật tin thành công!", "room_id": roomId}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      print("Error updating room: $e");
      return shelf.Response.internalServerError(
          body: jsonEncode({"success": false, "error": e.toString()}),
          headers: _jsonHeaders);
    }
  });

  final server = await shelf_io.serve(router, '0.0.0.0', 8080);
  print('Server running at HTTP://${server.address.host}:${server.port}');
}