class RoomModel {
  final int id;
  final String imageUrl;
  final String price;
  final String address;
  final String title;

  RoomModel({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.title,
    this.address = 'Gia Lâm',
  });

  // Hàm quan trọng để nhận dữ liệu từ API server.dart 
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      title: json['title'] ?? 'Không có tiêu đề',
      // Nếu thumbnail null thì dùng ảnh mặc định
      imageUrl: json['thumbnail'] ?? 'https://via.placeholder.com/100', 
      price: "${json['price']} VNĐ",
      address: json['address'] ?? 'Gia Lâm',
    );
  }
}