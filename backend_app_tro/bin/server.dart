import 'dart:convert';
import 'dart:io';
import 'package:cloudinary/cloudinary.dart' as cloud;
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:dotenv/dotenv.dart'; // Import thư viện dotenv

final _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

// Khởi tạo Cloudinary
late final cloud.Cloudinary _cloudinary;

Future<MySQLConnection> getDbConnection() async {
  print("⌛ Đang thử kết nối MySQL (XAMPP)...");
  try {
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
  } catch (e) {
    print("❌ LỖI KẾT NỐI MYSQL: $e");
    rethrow;
  }
}

void main() async {
  // 1. KHỞI TẠO ĐỐI TƯỢNG DOTENV
  final env = DotEnv(); 

  try {
    final envFile = File('cloudinary.env');

    if (!envFile.existsSync()) {
      print("❌ Lỗi: Không tìm thấy file cloudinary.env");
      exit(1);
    }

    // 2. LOAD FILE THÔNG QUA ĐỐI TƯỢNG env
    env.load(['cloudinary.env']); 
    print("✅ Đã load file cloudinary.env thành công");
  } catch (e) {
    print("❌ Lỗi khi load file cloudinary.env: $e");
    exit(1);
  }

  // 3. TRUY XUẤT BIẾN TỪ ĐỐI TƯỢNG env (Sửa các lỗi gạch đỏ)
  final cloudName = env['CLOUDINARY_CLOUD_NAME'];
  final apiKey = env['CLOUDINARY_API_KEY'];
  final apiSecret = env['CLOUDINARY_API_SECRET'];
 
  if (cloudName == null || cloudName.isEmpty) {
    print("❌ Lỗi: CLOUDINARY_CLOUD_NAME không có trong file env");
    exit(1);
  }

  _cloudinary = cloud.Cloudinary.signedConfig(
    apiKey: apiKey ?? "",
    apiSecret: apiSecret ?? "",
    cloudName: cloudName,
  );

  print("🚀 Cloudinary đã sẵn sàng - Cloud: $cloudName");

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

  // API Đăng tin PRO 
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

  final server = await shelf_io.serve(router, '0.0.0.0', 8080);
  print('🚀 BACKEND ĐANG CHẠY TẠI HTTP://${server.address.host}:${server.port}');
}