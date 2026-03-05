import 'package:flutter/material.dart';

/// A simple data model for a room listing. You can extend this class
/// with additional fields as needed (e.g. description, id, etc.).
class RoomModel {
  final String imageUrl;
  final String price;
  final String address;

  RoomModel({
    required this.imageUrl,
    required this.price,
    this.address = 'Gia Lâm',
  });
}

/// A card widget that mimics the appearance of a listing in the Chợ Tốt
/// application.
///
/// - The left side shows a preview image of the room.
/// - The title/price bar at the top of the right side uses a green
///   background (#4CAF50).
/// - The price text itself is displayed on a yellow background
///   (#FFEB3B).
/// - The address is shown beneath the price and defaults to "Gia Lâm".
class RoomCard extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String address;

  const RoomCard({
    Key? key,
    required this.imageUrl,
    required this.price,
    this.address = 'Gia Lâm',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 6.0),
                    color: const Color(0xFF4CAF50), // green
                    child: Text(
                      price,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Address
                  Text(
                    address,
                    style: const TextStyle(fontSize: 14.0),
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
