import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart'; // SỬA: Import package viền nét đứt
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // SỬA: Import package icon

class DangTinScreen extends StatefulWidget {
  const DangTinScreen({super.key});

  @override
  State<DangTinScreen> createState() => _DangTinScreenState();
}

class _DangTinScreenState extends State<DangTinScreen> {

  String _selectedType = 'Phòng trọ'; // SỬA: Trạng thái chọn loại hình
  final Map<String, bool> _amenities = { // SỬA: Trạng thái chọn tiện ích
    'Điều hòa': false,
    'Nóng lạnh': false,
  };

  final _addressController = TextEditingController(text: 'Số 12, Ngõ 45, Cầu Giấy, Hà Nội');
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    // SỬA: Định nghĩa màu xanh chủ đạo giống ảnh
    const Color primaryGreen = Color(0xFF32D74B);

    return Scaffold(
      backgroundColor: Colors.white, // SỬA: Nền trắng cho toàn màn hình
      appBar: AppBar(
        title: const Text('Đăng tin cho thuê',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        elevation: 1, // SỬA: Bóng đổ nhẹ để tách biệt
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text("ĐĂNG", // SỬA: Viết hoa
                  style: TextStyle(
                      color: primaryGreen, // SỬA: Màu xanh giống ảnh
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN ẢNH ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDottedImageUploadSection(), // SỬA: Dùng viền nét đứt
                  const SizedBox(height: 12),
                  _buildSmallImagePlaceholders(), // SỬA: Thêm 2 ô nhỏ bên dưới
                ],
              ),
            ),

            // --- TIÊU ĐỀ XÁM ---
            Container(
              width: double.infinity,
              color: const Color(0xFFF0F0F0), // SỬA: Màu nền xám nhạt
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: const Text('THÔNG TIN CHI TIẾT',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)), // SỬA: Đường gạch dưới

            // --- NỘI DUNG ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOẠI HÌNH ---
                  _buildLabel("Loại hình *"),
                  Row(
                    children: [
                      _buildChip("Phòng trọ", isSelected: _selectedType == "Phòng trọ"),
                      const SizedBox(width: 8),
                      _buildChip("Chung cư mini", isSelected: _selectedType == "Chung cư mini"),
                      const SizedBox(width: 8),
                      _buildChip("Nhà nguyên căn", isSelected: _selectedType == "Nhà nguyên căn"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- ĐỊA CHỈ ---
                  _buildLabel("Địa chỉ cho thuê *"),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      // SỬA: Thay đổi nội dung hintText và làm mờ nó
                      hintText: "Ví dụ:227 Trâu Quỳ - Gia Lâm - Hà Nội",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), // Làm mờ chữ gợi ý

                      suffixIcon: const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0E0E0))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF32D74B))),
                    ),
                  ),

                  // --- DIỆN TÍCH & GIÁ ---
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Diện tích (m²) *", "Ví dụ: 25", controller: _areaController)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildTextField("Giá thuê (VNĐ/tháng) *", "Ví dụ: 3500000", controller: _priceController)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- TIỀN CỌC ---
                  _buildTextField("Số tiền cọc (VNĐ)", "Nhập số tiền cọc", controller: _depositController),
                  const SizedBox(height: 16),

                  // --- TIỆN ÍCH ---
                  _buildLabel("Tiện ích có sẵn"),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmenityCheck(
                          'Điều hòa', 
                          FontAwesomeIcons.snowflake,
                          iconColor: Colors.blue.shade400, // Màu icon xanh dương
                          textColor: Colors.black87,       // Chữ để màu đen cho dễ đọc giống ảnh
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAmenityCheck(
                          'Nóng lạnh', 
                          FontAwesomeIcons.hotjar,
                          iconColor: Colors.redAccent,    // Màu icon đỏ cam
                          textColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen, // SỬA: Màu xanh giống ảnh
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            debugPrint("Địa chỉ: ${_addressController.text}");
            debugPrint("Tiện ích Điều hòa: ${_amenities['Điều hòa']}");
          },
          child: const Text('Đăng tin ngay',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // --- HÀM HELPER ĐÃ TỐI ƯU ---

  // SỬA: Hàm làm khung viền nét đứt
  Widget _buildDottedImageUploadSection() {
    return DottedBorder(
      color: Colors.grey.shade400, // SỬA: Màu viền xám
      strokeWidth: 1,
      dashPattern: const [8, 4], // SỬA: Nét 8px, khoảng 4px
      borderType: BorderType.RRect,
      radius: const Radius.circular(10), // SỬA: Bo góc khớp container
      padding: const EdgeInsets.all(1),
      child: Container(
        width: double.infinity,
        height: 130, // SỬA: Giảm chiều cao cho gọn
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade50, // SỬA: Nền xám rất nhạt
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 45, color: Color(0xFFBCAAA4)), // SỬA: Icon nhà rỗng, màu nâu nhạt
            SizedBox(height: 8),
            Text("Thêm ảnh phòng/căn hộ", style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 4),
            Text("(Nên có ảnh WC và bếp)", style: TextStyle(fontSize: 11, color: Colors.grey)), // SỬA: Font chữ nhỏ hơn
          ],
        ),
      ),
    );
  }

  // SỬA: Thêm 2 ô nhỏ "nơi chứa ảnh" ở dưới khung lớn
  Widget _buildSmallImagePlaceholders() {
    return Row(
      children: [
        _buildSmallIconBox(),
        const SizedBox(width: 10),
        _buildSmallIconBox(),
      ],
    );
  }

  // SỬA: Widget ô nhỏ có dấu '+' xám nhạt
  Widget _buildSmallIconBox() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(Icons.add, color: Colors.grey.shade300, size: 20),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0), // SỬA: Tinh chỉnh padding
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87)),
    );
  }

  // SỬA: Tách riêng TextField cho gọn và hỗ trợ controller
  Widget _buildTextField(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF32D74B))),
          ),
        ),
      ],
    );
  }

  // SỬA: Tối ưu Chip để đổi màu khi chọn
  Widget _buildChip(String label, {bool isSelected = false}) {
    Color primaryGreen = const Color(0xFF32D74B);
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
          color: isSelected ? primaryGreen : Colors.black87, // SỬA: Chữ xanh khi chọn, đen khi không
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedType = label; // SỬA: Cập nhật state khi chọn
        });
      },
      selectedColor:primaryGreen.withValues(alpha: 0.12), // SỬA: Nền xanh nhạt khi chọn
      backgroundColor: Colors.white, // SỬA: Nền trắng khi không chọn
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(
          color: isSelected ? primaryGreen.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: const StadiumBorder(),
    );
  }

  // SỬA: Widget custom để Checkbox có icon và text đúng kiểu ảnh
  Widget _buildAmenityCheck(String label, IconData iconData, {Color? iconColor, Color? textColor}) {
    return Row(
      children: [
        Checkbox(
          value: _amenities[label] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _amenities[label] = value!;
            });
          },
          activeColor: const Color(0xFF32D74B),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 12),//khoảng cách checkbox và icon
        // SỬA: Thêm màu cho Icon
        Icon(iconData, size: 18, color: iconColor ?? Colors.grey.shade600), 
        const SizedBox(width: 8),
        // SỬA: Thêm màu cho Text
        Text(
          label,
          style: TextStyle(
            fontSize: 14, 
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}