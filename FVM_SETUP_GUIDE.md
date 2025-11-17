# 🚀 Hướng Dẫn Thiết Lập Project Flutter Với FVM & ONNX Runtime

## 📋 Danh Sách Kiểm Tra - Các Lệnh Cần Chạy Ngay Lập Tức

Chạy các lệnh sau **theo thứ tự** trong thư mục gốc của project:

### 1️⃣ Cài Đặt FVM (nếu chưa có)
```powershell
# Kiểm tra xem FVM đã cài chưa
fvm --version

# Nếu chưa cài, cài đặt thông qua pub (yêu cầu Dart đã cài)
dart pub global activate fvm

# Hoặc cài thông qua Chocolatey (trên Windows)
choco install fvm
```

### 2️⃣ Khởi Tạo FVM Cho Project
```powershell
# Cài đặt phiên bản Flutter 3.22.2
fvm install 3.22.2

# Gán phiên bản Flutter cho project này
fvm use 3.22.2

# Xác minh cấu hình
fvm list
```

### 3️⃣ Cập Nhật Dependencies (onnxruntime và flutter_riverpod)
```powershell
# Cách 1: Chạy từng lệnh riêng
fvm flutter pub add onnxruntime
fvm flutter pub add flutter_riverpod

# HOẶC

# Cách 2: Chạy lệnh kết hợp
fvm flutter pub add onnxruntime flutter_riverpod
```

### 4️⃣ Lấy Dependencies
```powershell
fvm flutter pub get
```

### 5️⃣ Kiểm Tra Cấu Hình
```powershell
# Kiểm tra phiên bản Flutter
fvm flutter --version

# Kiểm tra pubspec.yaml đã cập nhật chưa
Get-Content pubspec.yaml
```

### 6️⃣ Xác Minh Cấu Hình VS Code
```powershell
# Kiểm tra file cấu hình VS Code
Get-Content .vscode/settings.json

# Kiểm tra file cấu hình FVM
Get-Content .fvm/fvm_config.json
```

---

## 📁 Các File Cấu Hình Đã Tạo

### ✅ `.fvm/fvm_config.json`
Nhân (pinned) phiên bản Flutter 3.22.2 cho project.

```json
{
  "flutterSdkVersion": "3.22.2",
  "flavors": {}
}
```

### ✅ `.vscode/settings.json`
Cấu hình VS Code để sử dụng Flutter từ `.fvm/flutter_sdk` và loại trừ `.fvm` khỏi tìm kiếm.

**Các thiết lập chính:**
- `dart.flutterSdkPath`: Trỏ tới `.fvm/flutter_sdk`
- `search.exclude`: Loại trừ `.fvm` khỏi tìm kiếm toàn cục
- `files.exclude`: Ẩn thư mục `flutter_sdk` khỏi file explorer
- `[dart]`: Bật format on save và auto-fix lỗi

### ✅ `.gitignore`
Đã cập nhật để:
- **Bỏ qua:** `.fvm/flutter_sdk/` (thư mục Flutter SDK do FVM tải xuống)
- **Giữ lại:** `.fvm/fvm_config.json` (để team khác có thể sử dụng đúng phiên bản)

### ✅ `android/app/build.gradle.kts`
Cập nhật `minSdk = 24` (bắt buộc cho onnxruntime):

```gradle-kotlin-dsl
defaultConfig {
    minSdk = 24  // Required for onnxruntime
    // ... rest of config
}
```

---

## 🔧 Dependencies Được Thêm

Sau khi chạy `fvm flutter pub add`, file `pubspec.yaml` sẽ có:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  onnxruntime: ^1.x.x        # Cho local AI inference
  flutter_riverpod: ^2.x.x   # Cho state management
```

---

## 💡 Lợi Ích Của Cấu Hình Này

| Tính Năng | Lợi Ích |
|-----------|---------|
| **FVM** | Tất cả team đều sử dụng Flutter 3.22.2, tránh lỗi "works on my machine" |
| **ONNX Runtime** | Chạy AI models (.onnx) trực tiếp trên thiết bị, không cần cloud |
| **Flutter Riverpod** | Quản lý state hiệu quả, reactive, dễ test |
| **minSdk = 24** | Hỗ trợ ~99% thiết bị Android, cần thiết cho onnxruntime |
| **VS Code** | Cấu hình unified cho team, tự động dùng Flutter từ FVM |

---

## 📞 Troubleshooting

### ❌ Lỗi: "fvm: command not found"
**Giải pháp:** 
```powershell
# Cài FVM bằng pub
dart pub global activate fvm

# Hoặc thêm vào PATH (nếu cài từ Chocolatey)
# Khởi động lại PowerShell
```

### ❌ Lỗi: "FAILURE: Build failed with an exception"
**Nguyên nhân:** Thường do minSdkVersion không tương thích  
**Giải pháp:** Đã cập nhật thành 24, hãy chạy:
```powershell
fvm flutter clean
fvm flutter pub get
fvm flutter build apk
```

### ❌ VS Code không nhận Flutter SDK từ FVM
**Giải pháp:**
1. Đóng VS Code hoàn toàn
2. Xóa thư mục `.dart_tool` nếu cần
3. Mở lại VS Code
4. Chạy "Flutter: Change Device or Emulator" từ Command Palette

---

## 🎯 Bước Tiếp Theo

1. **Chạy các lệnh:** Thực hiện tất cả 6 lệnh ở phần "Danh Sách Kiểm Tra"
2. **Cấu hình IDE:** Đảm bảo VS Code nhận phiên bản Flutter đúng
3. **Clone model:** Tải models `.onnx` vào thư mục `assets/models/`
4. **Implement inference:** Tạo service để load và chạy models bằng onnxruntime
5. **Setup Riverpod:** Tạo providers cho state management

---

## 📚 Tài Liệu Tham Khảo

- [FVM Documentation](https://fvm.app/)
- [ONNX Runtime Flutter](https://pub.dev/packages/onnxruntime)
- [Flutter Riverpod](https://riverpod.dev/)
- [Flutter Official Docs](https://flutter.dev/docs)

---

**✨ Project của bạn giờ đã sẵn sàng cho AI inference local với Flutter!**
