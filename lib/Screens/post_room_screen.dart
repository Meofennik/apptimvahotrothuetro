import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Nhớ thêm image_picker vào pubspec.yaml
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class PostRoomScreen extends StatefulWidget {
  @override
  _PostRoomScreenState createState() => _PostRoomScreenState();
}

class _PostRoomScreenState extends State<PostRoomScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  
  bool _isSubmitting = false; // Biến để disable button
  
  // Amenities selection
  List<String> selectedAmenities = [];
  final List<Map<String, String>> amenitiesList = [
    {'name': 'WiFi', 'icon': '📡'},
    {'name': 'Điều hòa', 'icon': '❄️'},
    {'name': 'Bếp', 'icon': '🍳'},
    {'name': 'Phòng tắm', 'icon': '🚿'},
    {'name': 'Giường', 'icon': '🛏️'},
    {'name': 'Tủ quần áo', 'icon': '👔'},
    {'name': 'Bàn làm việc', 'icon': '💼'},
    {'name': 'Tivi', 'icon': '📺'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (selected != null) {
      setState(() {
        _image = selected;
      });
    }
  }

  Future<void> _submitPost() async {
  // Sửa dấu != thành == và thêm kiểm tra tiêu đề để chặt chẽ hơn
  if (_image == null || 
      _titleController.text.isEmpty || 
      _priceController.text.isEmpty || 
      _addressController.text.isEmpty) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Vui lòng chọn ảnh và điền đầy đủ thông tin!"), 
        backgroundColor: Colors.red
      ),
    );
    return;
  }
      setState(() => _isSubmitting = true);

    try {
      print("🚀 Bắt đầu đăng tin...");
      
      // Get userId from AuthService
      int? userId = await AuthService.getUserId();
      if (userId == null || userId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: Không tìm thấy user ID"), backgroundColor: Colors.red),
        );
        return;
      }
      
      // Bước 1: Upload ảnh lên Cloudinary (tùy chọn)
      String imageUrl = 'default_room_image';
      try {
        final imageBytes = await _image!.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        
        final uploadResponse = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/add_room_pro'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'image_base64': base64Image}),
        ).timeout(const Duration(seconds: 30));

        if (uploadResponse.statusCode == 200) {
          final uploadData = jsonDecode(uploadResponse.body);
          imageUrl = uploadData['imageUrl'] ?? 'default_room_image';
          print("✅ Upload ảnh thành công: $imageUrl");
        }
      } catch (e) {
        print("📝 Host ảnh lên Cloudinary thất bại, dùng default image: $e");
      }

      // Bước 2: Lưu thông tin phòng vào database
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/add_room'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'title': _titleController.text,
          'price': _priceController.text,
          'address': _addressController.text,
          'image_url': imageUrl,
          'amenities': selectedAmenities, // Thêm amenities vào payload
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        print("✅ Đăng tin thành công!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đăng tin thành công!"), backgroundColor: Colors.green),
        );
        
        // Quay về trang chủ
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        print("❌ Lỗi: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Đăng tin thất bại. Vui lòng thử lại!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("❌ Lỗi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
            
            // Amenities Section
            Text(
              "Tiện nghi phòng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenitiesList.map((amenity) {
                bool isSelected = selectedAmenities.contains(amenity['name']);
                return FilterChip(
                  label: Text("${amenity['icon']} ${amenity['name']}"),
                  selected: isSelected,
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.green.withOpacity(0.7),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedAmenities.add(amenity['name']!);
                      } else {
                        selectedAmenities.remove(amenity['name']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: 30),
            
            // Nút đăng bài
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("ĐĂNG TIN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}