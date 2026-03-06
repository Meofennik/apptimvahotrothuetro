class User {
  final int id;
  final String fullname;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        fullname: json['fullname'],
        email: json['email'],
        avatar: json['avatar'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'email': email,
        'avatar': avatar,
      };
}
