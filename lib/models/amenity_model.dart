class AmenityModel {
  final int id;
  final int roomId;
  final String name; // Ví dụ: "Wifi miễn phí", "Điều hòa"
  final String? icon;

  AmenityModel({
    required this.id,
    required this.roomId,
    required this.name,
    this.icon,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: int.parse(json['id'].toString()),
      roomId: int.parse(json['room_id'].toString()),
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'name': name,
      'icon': icon,
    };
  }
}