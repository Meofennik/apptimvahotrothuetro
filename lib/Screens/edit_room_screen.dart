import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:apptimvahotrothuetro/services/auth_service.dart';

class EditRoomScreen extends StatefulWidget {
  final dynamic room;

  const EditRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  List<String> selectedAmenities = [];
  bool _isSubmitting = false;
  bool _isLoadingAmenities = true;
  int? _currentUserId;

  final List<Map<String, String>> amenitiesList = [
    {'name': 'WiFi', 'icon': '📡'},
    {'name': 'Điều hòa', 'icon': '❄️'},
    {'name': 'Bếp', 'icon': '🍳'},
    {'name': 'Phòng tắm', 'icon': '🚿'},
    {'name': 'Giường', 'icon': '🛏️'},
    {'name': 'Tủ quần áo', 'icon': '👔'},
    {'name': 'Bàn làm việc', 'icon': '💼'},
    {'name': 'Tivi', 'icon': '📺'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Initialize screen - load user ID and amenities
Future<void> _initializeScreen() async {
    _currentUserId = await AuthService.getUserId();
    // Làm sạch giá tiền: Ép kiểu để bỏ đuôi .00
    String rawPrice = widget.room['price']?.toString() ?? '';
    double? priceDouble = double.tryParse(rawPrice);
    if (priceDouble != null) {
      rawPrice = priceDouble.toInt().toString(); 
    }
    _titleController = TextEditingController(text: widget.room['title'] ?? '');
    _priceController = TextEditingController(text: rawPrice); 
    _addressController = TextEditingController(text: widget.room['address'] ?? '');
    _descriptionController = TextEditingController(text: widget.room['description'] ?? '');
    await _fetchAmenities();
  }

  Future<void> _fetchAmenities() async {
    try {
      //ép kiểu sang int
      final int roomId = int.tryParse(widget.room['id'].toString()) ?? 0;
      print("[DEBUG] Fetching amenities for room ID: $roomId");

      final response = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/amenities/$roomId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final amenities = data is List ? data : data['amenities'] ?? [];
        
        setState(() {
          selectedAmenities = amenities
              .map((a) => a is String ? a : a['name']?.toString() ?? '')
              .toList();
          _isLoadingAmenities = false;
        });
        print("[SUCCESS] Loaded ${selectedAmenities.length} amenities");
      } else {
        setState(() => _isLoadingAmenities = false);
      }
    } catch (e) {
      print("[ERROR] Error fetching amenities: $e");
      setState(() => _isLoadingAmenities = false);
    }
  }

 Future<void> _submitUpdate() async {
    // Tự động lọc bỏ các dấu chấm, phẩy hoặc khoảng trắng trong giá tiền
    String cleanPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (_titleController.text.isEmpty ||
        cleanPrice.isEmpty || // Đã sửa
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final int roomId = int.tryParse(widget.room['id'].toString()) ?? 0;
      print("[DEBUG] Updating room ID: $roomId");

      // Update room details
      final updateResponse = await http
          .post(
            Uri.parse('http://10.0.2.2:8080/api/update_room'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'room_id': roomId,
              'user_id': _currentUserId,
              'title': _titleController.text,
              'price': cleanPrice, // GỬI GIÁ TIỀN ĐÃ LÀM SẠCH LÊN SQL
              'address': _addressController.text,
              'description': _descriptionController.text,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (updateResponse.statusCode != 200) {
        throw Exception('Failed to update room: ${updateResponse.statusCode}');
      }

      print("[SUCCESS] Room updated successfully");

      // Update amenities if changed
      await _updateAmenities(roomId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật tin đăng thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("[ERROR] Error updating room: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Update amenities for the room
  Future<void> _updateAmenities(int roomId) async {
    try {
      print("[DEBUG] Updating amenities for room $roomId");

      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:8080/api/update_amenities'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'room_id': roomId,
              'amenities': selectedAmenities,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("[SUCCESS] Amenities updated successfully");
      } else {
        print("[ERROR] Failed to update amenities: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Error updating amenities: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa tin đăng", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Tiêu đề bài đăng *",
                hintText: "VD: Phòng trọ khép kín gần VNUA",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // PRICE
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Giá thuê (VNĐ/tháng) *",
                suffixText: "đ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ADDRESS
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Địa chỉ cụ thể *",
                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // DESCRIPTION
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Mô tả chi tiết",
                hintText: "Mô tả thêm về phòng, điều kiện, quy tắc...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // AMENITIES SECTION
            const Text(
              "Tiện nghi phòng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoadingAmenities)
              const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF32D74B),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenitiesList.map((amenity) {
                  bool isSelected = selectedAmenities.contains(amenity['name']);
                  return FilterChip(
                    label: Text("${amenity['icon']} ${amenity['name']}"),
                    selected: isSelected,
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green.withOpacity(0.7),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAmenities.add(amenity['name']!);
                        } else {
                          selectedAmenities.remove(amenity['name']!);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 40),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32D74B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        "Cập nhật tin đăng",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
