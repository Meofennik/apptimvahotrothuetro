class UserModel {
  final int id;
  final String fullname;
  final String email;
  final String? password; // Có thể null khi nhận từ API về (bảo mật)
  final String? avatar;

  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.password,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'avatar': avatar,
    };
  }
}