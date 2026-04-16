import 'dart:async';
import 'dart:convert';
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
    final String price = room['price']?.toString() ?? '0';
    final String address = room['address'] ?? 'Đang cập nhật...';
    
    // Rất thông minh: Dự phòng việc bạn lưu link nhầm vào description lúc trước
    final String? imageUrl = room['image_url'] ?? room['description'] ?? room['thumbnail'];

    return Card(
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