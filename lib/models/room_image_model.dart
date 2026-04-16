class RoomImageModel {
  final int id;
  final int roomId;
  final String imageUrl;

  RoomImageModel({
    required this.id,
    required this.roomId,
    required this.imageUrl,
  });

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      id: int.parse(json['id'].toString()),
      roomId: int.parse(json['room_id'].toString()),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'image_url': imageUrl,
    };
  }
}