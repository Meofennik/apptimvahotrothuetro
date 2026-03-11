import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String price;
  final String address;

  const RoomCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 4, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh trọ
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                // Xử lý lỗi ảnh 
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 2. Chi tiết tin đăng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề trọ
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Giá tiền 
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Địa chỉ & Icon 
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
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
      ),
    );
  }
}