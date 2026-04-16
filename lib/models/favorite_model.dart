class FavoriteModel {
  final int id;
  final int userId;
  final int roomId;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.roomId,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      roomId: int.parse(json['room_id'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
    };
  }
}