import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Nhớ thêm image_picker vào pubspec.yaml
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRoomScreen extends StatefulWidget {
  @override
  _PostRoomScreenState createState() => _PostRoomScreenState();
}

class _PostRoomScreenState extends State<PostRoomScreen> {
  // 1. Khai báo các Controller và biến logic
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Lưu ảnh đã chọn

  // 2. Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Tối ưu dung lượng để upload nhanh hơn
    );
    if (selected != null) {
      setState(() {
        _image = selected;
      });
    }
  }

  // 3. Hàm gửi dữ liệu lên Backend (kết nối tới 10.0.2.2 của Thế Anh)
  Future<void> _submitPost() async {
    if (_image == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn ảnh và nhập đủ thông tin!")),
      );
      return;
    }

    // Ở bước này, bạn sẽ upload ảnh lên Cloudinary trước để lấy URL
    // Tạm thời mình giả định đã có URL hoặc gửi thông tin cơ bản
    final url = Uri.parse('http://10.0.2.2:8080/api/add_room');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': 1, // ID người dùng hiện tại (lấy từ session login)
          'title': _titleController.text,
          'price': _priceController.text,
          'address': _addressController.text,
          'image_url': 'link_anh_tu_cloudinary', // Sẽ thay bằng URL thật sau
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng tin thành công!")),
        );
        Navigator.pop(context); // Quay về trang trước
      }
    } catch (e) {
      print("Lỗi kết nối Backend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng tin cho thuê", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô chọn ảnh bám sát thiết kế
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.green),
                          SizedBox(height: 8),
                          Text("Thêm hình ảnh bài đăng", style: TextStyle(color: Colors.green)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_image!.path), fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 20),
            
            // Các ô nhập liệu
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Tiêu đề bài đăng *",
                hintText: "VD: Phòng trọ khép kín gần VNUA",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Giá thuê (VNĐ/tháng) *",
                suffixText: "đ",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Địa chỉ cụ thể *",
                prefixIcon: Icon(Icons.location_on, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Nút đăng bài màu xanh lá chuẩn nhóm 6
            ElevatedButton(
              onPressed: _submitPost,
              child: Text("ĐĂNG TIN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}