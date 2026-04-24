import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apptimvahotrothuetro/services/auth_service.dart';

class RoomDetailScreen extends StatefulWidget {
  final dynamic room;
  const RoomDetailScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;
  int? _currentUserId;

  List<dynamic> _amenities = [];
  bool _isLoadingAmenities = true;

  // Quản lý Album ảnh
  List<String> _albumImages = [];
  final PageController _pageController = PageController();

  // Hàm chuyển đổi "1000000.00" thành "1.000.000"
  String formatPrice(String? priceRaw) {
    if (priceRaw == null || priceRaw.isEmpty) return '0';
    // Ép kiểu về double trước để xử lý phần ".00"
    double? priceDouble = double.tryParse(priceRaw.toString());
    if (priceDouble == null) return '0';
    // Chuyển sang số nguyên
    int priceInt = priceDouble.toInt();
    // Dùng Regex để chèn dấu chấm vào mỗi 3 chữ số
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    _isFavorited =
        (widget.room['is_favorited'] == 1 ||
        widget.room['is_favorited'] == true);

    // sẵn ảnh bìa vào danh sách để hiển thị luôn
    if (widget.room['image_url'] != null) {
      _albumImages.add(widget.room['image_url']);
    }

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _currentUserId = await AuthService.getUserId();
    _fetchAmenities();
    _fetchAlbumImages(); // Gọi hàm lấy ảnh
  }

  // HÀM MỚI: Lấy danh sách ảnh từ Server
  Future<void> _fetchAlbumImages() async {
    try {
      final roomId = widget.room['id'];
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/room_images/$roomId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> fetchedImages = List<String>.from(data['images'] ?? []);

        setState(() {
          // Lọc trùng lặp ảnh bìa
          for (var img in fetchedImages) {
            if (!_albumImages.contains(img)) _albumImages.add(img);
          }
        });
      }
    } catch (e) {
      print("Lỗi tải album: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thả tim!')),
      );
      return;
    }

    setState(() => _isTogglingFavorite = true);

    try {
      final int roomId = int.tryParse(widget.room['id'].toString()) ?? 0;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/toggle_favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'user_id': _currentUserId, 'room_id': roomId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() => _isFavorited = data['is_favorited']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("[ERROR] Toggle favorite error: $e");
    } finally {
      setState(() => _isTogglingFavorite = false);
    }
  }

  Future<void> _fetchAmenities() async {
    try {
      final int roomId = int.tryParse(widget.room['id'].toString()) ?? 0;

      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/amenities/$roomId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _amenities = data['amenities'] ?? [];
          _isLoadingAmenities = false;
        });
      } else {
        setState(() => _isLoadingAmenities = false);
      }
    } catch (e) {
      setState(() => _isLoadingAmenities = false);
    }
  }

  // XÂY DỰNG SLIDER ẢNH
  Widget _buildImageSlider() {
    if (_albumImages.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _albumImages.length,
          itemBuilder: (context, index) {
            return Image.network(
              _albumImages[index],
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const Center(child: Icon(Icons.broken_image)),
            );
          },
        ),

        // Hiện nút mũi tên nếu có nhiều hơn 1 ảnh
        if (_albumImages.length > 1) ...[
          Positioned(
            left: 5,
            top: 100,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 100,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black),
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          // Chỉ báo số ảnh (1/5)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.room['title'] ?? 'Không có tiêu đề';
    final String price = formatPrice(widget.room['price']?.toString());
    final String address = widget.room['address'] ?? 'Không có địa chỉ';
    String rawDesc = widget.room['description'] ?? '';
    String displayDescription = rawDesc.startsWith('http')
        ? 'Chưa có mô tả chi tiết'
        : rawDesc;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chi tiết phòng",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gọi Widget Slider Ảnh
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: _buildImageSlider(),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$price VNĐ/tháng',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(address)),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayDescription,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tiện nghi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingAmenities)
                    const CircularProgressIndicator()
                  else
                    Wrap(
                      spacing: 8,
                      children: _amenities
                          .map((a) => Chip(label: Text(a['name'])))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
