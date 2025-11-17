# 🎯 Quy Trình Làm Việc Với Project Flutter + FVM + ONNX Runtime

## 👥 Cho Các Thành Viên Mới Trong Team

### 1️⃣ Clone Project
```powershell
git clone <repository-url>
cd app_map_limit
```

### 2️⃣ Cài Đặt FVM (chỉ cần lần đầu)
```powershell
# Nếu FVM chưa cài
dart pub global activate fvm
```

### 3️⃣ Thiết Lập Flutter SDK từ FVM
```powershell
# FVM tự động đọc .fvm/fvm_config.json
fvm install

# Gán cho project
fvm use 3.22.2
```

### 4️⃣ Cập Nhật Dependencies
```powershell
fvm flutter pub get
```

### 5️⃣ Mở Project Trong VS Code
```powershell
code .
```

**VS Code sẽ tự động:**
- ✅ Dùng Flutter SDK từ `.fvm/flutter_sdk`
- ✅ Loại trừ `.fvm` khỏi tìm kiếm
- ✅ Gợi ý cài các extensions cần thiết

---

## ⚡ Lệnh Thường Dùng

### Chạy App
```powershell
# Trên device/emulator đã kết nối
fvm flutter run

# Với release mode
fvm flutter run --release
```

### Build APK
```powershell
fvm flutter build apk
```

### Build iOS (macOS only)
```powershell
fvm flutter build ios
```

### Format Code
```powershell
fvm flutter format .
```

### Analyze Code
```powershell
fvm flutter analyze
```

### Xem Phiên Bản Flutter Hiện Tại
```powershell
fvm flutter --version
```

---

## 🧪 Testing

### Unit Tests
```powershell
fvm flutter test
```

### Widget Tests
```powershell
fvm flutter test test/widget_test.dart
```

---

## 🚀 Sử Dụng ONNX Runtime

### Cơ Bản
```dart
import 'package:onnxruntime/onnxruntime.dart';

void main() async {
  // Khởi tạo
  await OrtEnv.instance();
  
  // Tạo session từ model file
  final session = OrtSession.fromAsset('assets/models/model.onnx');
  
  // Chạy inference
  final inputs = <List<List<double>>>[[[1.0, 2.0, 3.0]]];
  final output = session.run(inputs);
  
  print(output);
}
```

### Với Riverpod
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onnxruntime/onnxruntime.dart';

final modelProvider = FutureProvider<OrtSession>((ref) async {
  await OrtEnv.instance();
  return OrtSession.fromAsset('assets/models/model.onnx');
});

final inferenceProvider = FutureProvider.family<List, List<double>>((ref, input) async {
  final session = await ref.watch(modelProvider);
  return session.run([input]);
});
```

---

## 📁 Cấu Trúc Thư Mục Khuyến Nghị

```
app_map_limit/
├── .fvm/
│   └── fvm_config.json          # Config FVM (commit vào git)
├── .vscode/
│   ├── settings.json            # VS Code settings
│   └── extensions.json          # Extensions recommendation
├── assets/
│   └── models/
│       ├── model1.onnx          # ONNX models
│       └── model2.onnx
├── lib/
│   ├── main.dart
│   ├── models/                  # Dart models
│   ├── services/
│   │   └── inference_service.dart  # ONNX inference logic
│   ├── providers/               # Riverpod providers
│   │   └── model_provider.dart
│   └── screens/
├── pubspec.yaml
└── README.md
```

---

## 🔒 Git Best Practices

### Những File Nên Commit
✅ `.fvm/fvm_config.json` - Đảm bảo team sử dụng đúng phiên bản  
✅ `.vscode/settings.json` - Cấu hình unified  
✅ `pubspec.yaml` & `pubspec.lock` - Đồng bộ dependencies  

### Những File Không Nên Commit
❌ `.fvm/flutter_sdk/` - FVM sẽ tự download  
❌ `build/`, `.dart_tool/`, `.pub-cache/` - Generated files  
❌ `.env` hoặc secret files  

---

## 🐛 Debug Workflow

### Bật Debug Logging
```dart
// Thêm vào main.dart
import 'dart:developer' as developer;

void main() {
  developer.Timeline.startSync('App Startup');
  runApp(const MyApp());
}
```

### Xem Device Logs
```powershell
fvm flutter logs
```

### Devtools
```powershell
fvm flutter pub global activate devtools
devtools
```

---

## 📊 Performance Optimization Cho ONNX

1. **Model Quantization:** Chuyển model sang INT8 để giảm kích thước & tăng tốc độ
2. **Batching:** Nếu có nhiều input, xử lý batch thay vì từng cái một
3. **GPU Acceleration:** Sử dụng GPU nếu device hỗ trợ (qua ONNX Runtime config)
4. **Caching:** Lưu model session để tái sử dụng

---

## 📞 Liên Hệ & Support

Nếu có vấn đề:
1. Kiểm tra `FVM_SETUP_GUIDE.md`
2. Chạy `fvm flutter doctor` để kiểm tra setup
3. Xóa cache: `fvm flutter clean && fvm flutter pub get`
4. Khởi động lại VS Code & emulator

---

**Happy Coding! 🚀**
