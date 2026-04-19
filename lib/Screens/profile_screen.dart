import 'package:apptimvahotrothuetro/Screens/favorite_screen.dart';
import 'package:apptimvahotrothuetro/Screens/post_room_screen.dart';
import 'package:apptimvahotrothuetro/services/user_services.dart';
import 'package:apptimvahotrothuetro/services/auth_service.dart';
import 'package:apptimvahotrothuetro/Screens/welcome_screen.dart';
import 'package:flutter/material.dart'; // Import trang đăng tin

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({Key? key, this.userId = 1}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: AuthService.getUserId(),
      builder: (context, userIdSnapshot) {
        if (userIdSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF32D74B)),
          );
        }

        final userId = userIdSnapshot.data ?? 0;

        if (userId == 0) {
          return Center(child: Text("Lỗi: Không tìm thấy user"));
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: UserService.getProfile(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF32D74B)),
              );
            }

            final user = snapshot.data ?? {};

            return Scaffold(
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 60, bottom: 20),
                    color: Colors.green,
                    width: double.infinity,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            user['avatar'] ?? 'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          user['fullname'] ?? "Khách",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'] ?? "",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.post_add, color: Colors.green),
                    title: const Text("Tin đã đăng"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: const Text("Tin đã lưu"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // chuyển sang tin yêu thích
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoriteScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Cài đặt"),
                    onTap: () {},
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // CHUYỂN SANG TRANG ĐĂNG TIN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostRoomScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "ĐĂNG TIN MỚI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: OutlinedButton(
                      onPressed: () async {
                        // Logout
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "ĐĂNG XUẤT",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
