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
    userName: "root",
    password: "", 
    databaseName: "apphotrotimvathuetro", 
  );
  await conn.connect();
  return conn;
}

void main() async {
  final router = Router();

  // Route mặc định để kiểm tra server
  router.get('/', (Request request) {
    return Response.ok('Server App Tim Tro dang hoat dong!');
  });

  // API 1: Lay danh sach tro 
  router.get('/api/rooms', (Request request) async {
    final conn = await getDbConnection();
    final result = await conn.execute("SELECT * FROM rooms");
    
    final rooms = <Map<String, dynamic>>[];
    for (final row in result.rows) {
      rooms.add(row.assoc());
    }
    
    await conn.close();
    return Response.ok(jsonEncode(rooms), headers: {'Content-Type': 'application/json'});
  });

  // API 2: Dang tin tro moi 
  router.post('/api/add-room', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final conn = await getDbConnection();
    
    await conn.execute(
      "INSERT INTO rooms (user_id, title, price, address, description, image_url) "
      "VALUES (:uid, :title, :price, :address, :desc, :img)",
      {
        "uid": payload['user_id'],
        "title": payload['title'],
        "price": payload['price'],
        "address": payload['address'],
        "desc": payload['description'],
        "img": payload['image_url'],
      },
    );

    await conn.close();
    return Response.ok(jsonEncode({"message": "Dang tin thanh cong!"}), 
      headers: {'Content-Type': 'application/json'});
  });

  // 3. Khoi chay server
  final server = await shelf_io.serve(router, '0.0.0.0', 8080);
  print('Backend dang chay tai http://${server.address.host}:${server.port}');
}