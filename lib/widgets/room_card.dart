import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class RoomCard extends StatefulWidget {
  final int roomId;
  final int userId;
  final String title;
  final String imageUrl;
  final String price;
  final String address;

  const RoomCard({
    Key? key,
    required this.roomId,
    required this.userId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.address,
  }) : super(key: key);

  @override
  _RoomCardState createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  late Future<bool> _isFavoritedFuture;

  @override
  void initState() {
    super.initState();
    _isFavoritedFuture = FavoriteService.isFavorited(userId: widget.userId, roomId: widget.roomId);
  }

  void _toggleFavorite(bool currentStatus) async {
    try {
      if (currentStatus) {
        // Remove from favorites
        await FavoriteService.removeFavorite(userId: widget.userId, roomId: widget.roomId);
      } else {
        // Add to favorites
        await FavoriteService.addFavorite(userId: widget.userId, roomId: widget.roomId);
      }

      // Refresh the favorite status
      setState(() {
        _isFavoritedFuture = FavoriteService.isFavorited(userId: widget.userId, roomId: widget.roomId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus ? "❌ Đã xóa khỏi yêu thích" : "❤️ Đã thêm vào yêu thích"),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh trọ với nút yêu thích
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.home, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              // Heart button
              Positioned(
                top: 8,
                right: 8,
                child: FutureBuilder<bool>(
                  future: _isFavoritedFuture,
                  builder: (context, snapshot) {
                    bool isFavored = snapshot.data ?? false;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavored ? Icons.favorite : Icons.favorite_border,
                          color: isFavored ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(isFavored),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Chi tiết tin đăng
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Giá tiền
                Text(
                  widget.price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Địa chỉ & Icon
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}