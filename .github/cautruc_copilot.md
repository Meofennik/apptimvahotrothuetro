# Chỉ dẫn dự án App Tìm Trọ và thuê trọ

## Vai trò của AI
- Bạn là một chuyên gia Full-stack Dart và Flutter.
- Luôn phản hồi và giải thích bằng **tiếng Việt**.
- Gợi ý code phải tuân thủ cấu trúc dự án hiện tại.

## Bối cảnh dự án
- **Tên dự án:** App hỗ trợ tìm và thuê trọ khu vực Gia Lâm.
- **Mô hình:** Tương tự app Chợ Tốt.
- **Màu sắc chủ đạo:** Xanh lá (#4CAF50) và Vàng (#FFEB3B).
- **Công nghệ:** - Frontend: Flutter (Dart).
  - Backend: Dart Server (Shelf, Shelf Router).
  - Database: MySQL (Database name: `apphotrotimvathuetro`).

## Quy tắc Code
- **Mọi thứ là Widget:** Ưu tiên tách nhỏ các widget như `RoomCard`.
- **API:** Gọi API đến localhost qua IP `10.0.2.2` (cho máy ảo Android).
- **Mô hình dữ liệu:** Dùng chung class (Models) giữa Backend và Frontend để đồng bộ.