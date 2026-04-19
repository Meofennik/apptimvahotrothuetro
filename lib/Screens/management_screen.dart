import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:apptimvahotrothuetro/services/auth_service.dart';
import 'package:apptimvahotrothuetro/Screens/edit_room_screen.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  late Future<List<dynamic>> _userRoomsFuture;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _currentUserId = await AuthService.getUserId();
    if (_currentUserId != null) {
      _userRoomsFuture = _fetchUserRooms();
      setState(() {});
    }
  }

  Future<List<dynamic>> _fetchUserRooms() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/user_rooms/$_currentUserId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải dữ liệu: $e');
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

  void _deleteRoom(int roomId, String roomTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin đăng'),
        content: Text('Bạn có chắc muốn xóa bài đăng "$roomTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteRoom(roomId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRoom(int roomId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/delete_room'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'room_id': roomId,
          'user_id': _currentUserId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa tin thành công'), backgroundColor: Colors.green),
        );
        setState(() {
          _userRoomsFuture = _fetchUserRooms();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa tin thất bại'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Vui lòng đăng nhập để quản lý tin đăng',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _userRoomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF32D74B)),
                SizedBox(height: 16),
                Text("Đang tải tin đăng của bạn..."),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final rooms = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return _buildRoomManagementCard(rooms[index]);
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.post_add, color: Colors.grey, size: 80),
              const SizedBox(height: 16),
              const Text("Bạn chưa đăng tin nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/post_room'),
                icon: const Icon(Icons.add),
                label: const Text('Đăng tin mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32D74B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // nút sửa và xóa
  Widget _buildRoomManagementCard(dynamic room) {
    final String title = room['title'] ?? 'Unknown Room';
    final String price = formatPrice(room['price']?.toString());
    final String address = room['address'] ?? 'Unknown Address';
    final String? imageUrl = room['image_url'] ?? room['description'];
    final int roomId = int.tryParse(room['id'].toString()) ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
              child: _buildImageWidget(imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$price VNĐ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditRoomScreen(room: room))).then((_) {
                            setState(() => _userRoomsFuture = _fetchUserRooms());
                          });
                        },
                        icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                        label: const Text('Sửa', style: TextStyle(color: Colors.blue)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue), padding: const EdgeInsets.symmetric(horizontal: 10)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _deleteRoom(roomId, title),
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(horizontal: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
      ),
    );
  }
}