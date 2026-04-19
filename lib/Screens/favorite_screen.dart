import 'package:flutter/material.dart';
import 'package:apptimvahotrothuetro/services/auth_service.dart';
import 'package:apptimvahotrothuetro/services/favorite_service.dart';
// Nhớ import đường dẫn đúng tới file room_detail_screen của bạn nhé:
import 'room_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  List<dynamic> _favorites = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 1. Tải danh sách phòng yêu thích
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    _currentUserId = await AuthService.getUserId();

    if (_currentUserId != null) {
      final result = await FavoriteService.getFavorites(_currentUserId!);
      if (result['success'] == true) {
        setState(() {
          _favorites = result['favorites'];
        });
      }
    }
    setState(() => _isLoading = false);
  }

  // 2. Hàm bỏ yêu thích trực tiếp trên thẻ
  Future<void> _removeFavorite(int roomId, String roomTitle) async {
    if (_currentUserId == null) return;

    // Gọi Service bạn đã viết sẵn
    final result = await FavoriteService.removeFavorite(
      userId: _currentUserId!,
      roomId: roomId,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã bỏ lưu phòng "$roomTitle"'),
          backgroundColor: Colors.green,
        ),
      );
      // Tải lại danh sách sau khi xóa
      _loadFavorites();
    }
  }

  // 3. Hàm định dạng tiền tệ (chuẩn Việt Nam)
  String formatPrice(String? priceRaw) {
    if (priceRaw == null || priceRaw.isEmpty) return '0';
    double? priceDouble = double.tryParse(priceRaw.toString());
    if (priceDouble == null) return '0';
    int priceInt = priceDouble.toInt();
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Tin đã lưu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentUserId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Vui lòng đăng nhập để xem Tin yêu thích',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF37DD63)),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "Bạn chưa lưu phòng trọ nào",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy thả tim những phòng bạn ưng ý nhé!",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final room = _favorites[index];
        final String title = room['title'] ?? 'Đang cập nhật...';
        final String price = formatPrice(room['price']?.toString());
        final String address = room['address'] ?? 'Đang cập nhật...';
        final String? imageUrl = room['image_url'] ?? room['description'];
        final int roomId = int.tryParse(room['id'].toString()) ?? 0;

        return GestureDetector(
          onTap: () {
            // Chuyển sang trang chi tiết khi bấm vào thẻ
            // Lưu ý: Đảm bảo room map này có trường is_favorited = 1 để trái tim đỏ
            room['is_favorited'] = 1;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomDetailScreen(room: room),
              ),
            ).then(
              (_) => _loadFavorites(),
            ); // Refresh lại nếu trong chi tiết họ bỏ tim
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // ẢNH BÌA
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageWidget(imageUrl),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // THÔNG TIN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$price VNĐ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // NÚT BỎ TIM
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeFavorite(roomId, title),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}
