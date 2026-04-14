import 'package:http/http.dart' as http;
import 'dart:io';

class PostService {
  static Future<bool> uploadRoomWithImage(Map<String, String> data, File imageFile) async {
    var uri = Uri.parse('http://10.0.2.2:8080/api/add_room_pro');
    var request = http.MultipartRequest('POST', uri);

    // Thêm các trường dữ liệu text
    request.fields.addAll(data);

    // Thêm file ảnh vào request
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    return response.statusCode == 200;
  }
}