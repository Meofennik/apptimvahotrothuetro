import 'dart:async';
import 'dart:convert';
import 'package:apptimvahotrothuetro/services/auth_service.dart';
import 'package:apptimvahotrothuetro/Screens/room_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomGrid extends StatefulWidget {
  const RoomGrid({super.key});

  @override
  State<RoomGrid> createState() => _RoomGridState();
}

class _RoomGridState extends State<RoomGrid> {
  late Future<List<dynamic>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRooms();
  }

  /// Hàm fetchRooms() - Gọi API và parse dữ liệu vào List<dynamic>
  Future<List<dynamic>> fetchRooms() async {
    print("[DEBUG] Fetching rooms from http://10.0.2.2:8080/api/rooms");
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/rooms'))
          .timeout(const Duration(seconds: 15));

      print("[DEBUG] Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print("[SUCCESS] Fetched ${jsonList.length} rooms successfully");
        return jsonList;
      } else {
        throw Exception('Server error: Status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print("[ERROR] Connection error: $e");
      throw Exception('Failed to connect to server. Please check if backend is running.');
    } on TimeoutException catch (e) {
      print("[ERROR] Timeout error: $e");
      throw Exception('Request timeout. Backend might be unresponsive.');
    } catch (e) {
      print("[ERROR] Unexpected error: $e");
      throw Exception('Error fetching rooms: $e');
    }
  }

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
      (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        // 1. TRẠNG THÁI: ĐANG TẢI DỮ LIỆU
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF32D74B)),
                  SizedBox(height: 16),
                  Text("Đang tải danh sách phòng..."),
                ],
              ),
            ),
          );
        }

        // 2. TRẠNG THÁI: CÓ LỖI
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _roomsFuture = fetchRooms();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32D74B),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 3. TRẠNG THÁI: CÓ DỮ LIỆU
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final rooms = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return _buildRoomCard(rooms[index]);
              },
            ),
          );
        }

        // 4. TRẠNG THÁI: KHÔNG CÓ DỮ LIỆU
        return const SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, color: Colors.grey, size: 60),
                SizedBox(height: 16),
                Text(
                  "Hiện chưa có phòng trọ nào",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Xây dựng thẻ phòng
  Widget _buildRoomCard(dynamic room) {
    final String title = room['title'] ?? 'Đang cập nhật...';
    final String price = formatPrice(room['price']?.toString());
    final String address = room['address'] ?? 'Đang cập nhật...';
    
    // Rất thông minh: Dự phòng việc bạn lưu link nhầm vào description lúc trước
    final String? imageUrl = room['image_url'] ?? room['description'] ?? room['thumbnail'];

    return GestureDetector(
      onTap: () {
        print("[DEBUG] Tapped room: $title");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(room: room),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Hình ảnh
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildImageWidget(imageUrl),
                ),
              ),
            ),

            // Phần Thông tin
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$price VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xử lý tải ảnh an toàn, đã xóa đoạn code thừa
  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF32D74B),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  
}

class RoomCardWidget extends StatefulWidget {
  final dynamic room;
  const RoomCardWidget({super.key, required this.room});

  @override
  State<RoomCardWidget> createState() => _RoomCardWidgetState();
}

class _RoomCardWidgetState extends State<RoomCardWidget> {
  bool _isFavorite = false;
  bool _isLoadingFav = false;

  @override
  @override
void initState() {
  super.initState();
  _isFavorite = (widget.room['is_favorited'] == 1); 
}

  Future<void> _toggleFavorite() async {
    int? currentUserId = await AuthService.getUserId();

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đăng nhập để thả tim!")),
      );
      return;
    }

    // 2. Đổi màu trái tim ngay lập tức để app cảm giác mượt mà (Optimistic UI)
    setState(() {
      _isFavorite = !_isFavorite;
      _isLoadingFav = true;
    });

    // 3. Gọi API ngầm ở dưới background
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/toggle_favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': currentUserId,
          'room_id': widget.room['id'],
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Đồng bộ lại trạng thái chính xác từ Server
        setState(() => _isFavorite = data['is_favorited']);
      } else {
        // Nếu lỗi, trả lại trạng thái cũ
        setState(() => _isFavorite = !_isFavorite);
        print("Lỗi từ server: ${data['message']}");
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
      print("Lỗi kết nối: $e");
    } finally {
      setState(() => _isLoadingFav = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.room['title'] ?? 'Đang cập nhật...';
    final String price = widget.room['price']?.toString() ?? '0';
    final String address = widget.room['address'] ?? 'Đang cập nhật...';
    final String? imageUrl = widget.room['image_url'] ?? widget.room['description'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION - Có thêm Nút Tim Đè Lên
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Ảnh nền
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _buildImageWidget(imageUrl),
                  ),
                ),
                
                // Nút Trái Tim ở góc trên bên phải
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: _isLoadingFav ? null : _toggleFavorite,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 16,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // INFO SECTION
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$price VNĐ',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey)),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF32D74B),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey)),
        );
      },
    );
  }
}