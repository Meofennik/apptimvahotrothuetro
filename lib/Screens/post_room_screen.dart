import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _descriptionController = TextEditingController(); 

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = []; // Dùng List để chứa nhiều ảnh
  final PageController _pageController = PageController();
  
  bool _isSubmitting = false;

  List<String> selectedAmenities = [];
  final List<Map<String, String>> amenitiesList = [
    {'name': 'WiFi', 'icon': '📡'}, {'name': 'Điều hòa', 'icon': '❄️'},
    {'name': 'Bếp', 'icon': '🍳'}, {'name': 'Phòng tắm', 'icon': '🚿'},
    {'name': 'Giường', 'icon': '🛏️'}, {'name': 'Tủ quần áo', 'icon': '👔'},
    {'name': 'Bàn làm việc', 'icon': '💼'}, {'name': 'Tivi', 'icon': '📺'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
      );

      if (selectedImages.isNotEmpty) {
        setState(() {
          _images.addAll(selectedImages); // Thêm ảnh mới vào danh sách
        });
      }
    } catch (e) {
      print("Lỗi khi chọn ảnh: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_images.isEmpty ||
        _titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ít nhất 1 ảnh và điền đủ thông tin!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null || userId == 0) throw Exception("Bạn cần đăng nhập");

      List<String> uploadedUrls = [];
      
      // Upload từng ảnh lên Cloudinary
      for (var img in _images) {
        final imageBytes = await img.readAsBytes();
        final uploadResponse = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/add_room_pro'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'image_base64': base64Encode(imageBytes)}),
        ).timeout(const Duration(seconds: 30));

        if (uploadResponse.statusCode == 200) {
          uploadedUrls.add(jsonDecode(uploadResponse.body)['imageUrl']);
        }
      }

      if (uploadedUrls.isEmpty) throw Exception("Lỗi tải ảnh lên hệ thống");

      // Lưu vào Database
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/add_room'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'title': _titleController.text,
          'price': _priceController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'images': uploadedUrls, // Đẩy toàn bộ mảng ảnh lên Server
          'amenities': selectedAmenities,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng tin thành công!"), backgroundColor: Colors.green));
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        throw Exception("Lỗi lưu dữ liệu");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- XÂY DỰNG GIAO DIỆN KHUNG TRƯỢT ẢNH ---
  Widget _buildImageCarousel() {
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 250, width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.add_photo_alternate, size: 50, color: Colors.green), SizedBox(height: 8), Text("Chọn ảnh (Có thể chọn nhiều)", style: TextStyle(color: Colors.green))],
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          // Khung trượt PageView
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_images[index].path), fit: BoxFit.cover),
                    // Số thứ tự ảnh
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
                        child: Text("${index + 1}/${_images.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Nút xóa ảnh
                    Positioned(
                      bottom: 10, right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () => _removeImage(index)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Nút mũi tên trái
          Positioned(
            left: 5, top: 100,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              ),
            ),
          ),
          // Nút mũi tên phải
          Positioned(
            right: 5, top: 100,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black),
                onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              ),
            ),
          ),
          // Nút thêm ảnh phụ
          Positioned(
            bottom: 10, left: 10,
            child: ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add, size: 16), label: const Text("Thêm"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng tin", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(), // Gọi Widget hiển thị ảnh
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tiêu đề *", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá thuê *", suffixText: "đ", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Địa chỉ *", prefixIcon: Icon(Icons.location_on, color: Colors.red), border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: "Mô tả chi tiết *", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            const Text("Tiện nghi phòng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: amenitiesList.map((amenity) {
                bool isSelected = selectedAmenities.contains(amenity['name']);
                return FilterChip(
                  label: Text("${amenity['icon']} ${amenity['name']}"), selected: isSelected,
                  backgroundColor: Colors.grey[200], selectedColor: Colors.green.withOpacity(0.7),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  onSelected: (selected) => setState(() => selected ? selectedAmenities.add(amenity['name']!) : selectedAmenities.remove(amenity['name']!)),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)),
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("ĐĂNG TIN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}