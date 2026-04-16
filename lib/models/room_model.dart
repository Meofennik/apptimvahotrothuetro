class RoomModel {
  final int id;
  final int userId;
  final String title;
  final String price;
  final String address;
  final String imageUrl;
  final String? description;
  final String? status;

  RoomModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.price,
    required this.address,
    required this.imageUrl,
    this.description,
    this.status,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title'] ?? '',
      price: "${json['price'] ?? 0} VND",
      address: json['address'] ?? '',
      imageUrl: json['description'] ?? json['thumbnail'] ?? 'https://via.placeholder.com/100',
      description: json['description'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'price': price,
      'address': address,
      'description': description,
      'status': status,
    };
  }
}