# ✅ Danh Sách Kiểm Tra Hoàn Tất (Project Setup Checklist)

## 📋 Pre-Setup Checklist

### Chuẩn Bị Môi Trường
- [ ] Dart SDK đã cài (phiên bản 3.10.0 trở lên)
- [ ] Flutter SDK đã cài (version mặc định, sẽ override bằng FVM)
- [ ] PowerShell 5.1 hoặc cao hơn
- [ ] Android SDK/NDK đã cài (nếu develop trên Android)
- [ ] Xcode đã cài (nếu develop trên iOS, macOS only)

---

## 🚀 Setup Checklist (Chạy Theo Thứ Tự)

### 1️⃣ FVM Installation
```powershell
# Chạy lệnh
dart pub global activate fvm

# Xác minh
dart pub global list | Select-String "fvm"
```
- [ ] FVM đã cài thành công
- [ ] Có thể chạy lệnh `fvm --version`

### 2️⃣ FVM Configuration
```powershell
# Chạy lệnh
fvm install 3.22.2
fvm use 3.22.2

# Xác minh
fvm list
fvm flutter --version
```
- [ ] Flutter 3.22.2 đã download thành công
- [ ] Lệnh `fvm flutter --version` trả về 3.22.2
- [ ] Thư mục `.fvm/flutter_sdk` tồn tại

### 3️⃣ Check Config Files
```powershell
# Xác minh các file đã tạo
Get-Content .fvm/fvm_config.json
Get-Content .vscode/settings.json
Get-Content .gitignore
```
- [ ] `.fvm/fvm_config.json` contains `"flutterSdkVersion": "3.22.2"`
- [ ] `.vscode/settings.json` contains `dart.flutterSdkPath`
- [ ] `.gitignore` contains `.fvm/flutter_sdk` ignore rule

### 4️⃣ Android Configuration
```powershell
# Kiểm tra build.gradle.kts
Get-Content android/app/build.gradle.kts | Select-String "minSdk"
```
- [ ] `minSdk = 24` được thiết lập trong `android/app/build.gradle.kts`

### 5️⃣ Dependencies Installation
```powershell
# Chạy lệnh
fvm flutter pub add onnxruntime flutter_riverpod

# Xác minh
fvm flutter pub get
```
- [ ] `onnxruntime` package đã cài
- [ ] `flutter_riverpod` package đã cài
- [ ] `pubspec.lock` đã update
- [ ] Không có error khi chạy `fvm flutter pub get`

### 6️⃣ VS Code Setup
```powershell
# Mở project
code .
```
- [ ] VS Code mở project
- [ ] Dart extension đã cài
- [ ] Flutter extension đã cài
- [ ] Notification để cài recommended extensions đã xuất hiện
- [ ] VS Code Command Palette: `Flutter: Change Device or Emulator` hoạt động

### 7️⃣ Verify Build Tools
```powershell
# Chạy doctor
fvm flutter doctor
```
- [ ] Tất cả ✓ hoặc ✓ (cần một số config tùy chọn)
- [ ] Android SDK OK
- [ ] (iOS: Xcode OK, nếu dev trên Mac)
- [ ] VS Code OK

### 8️⃣ Test Build
```powershell
# Chạy clean
fvm flutter clean

# Thử build
fvm flutter build apk  # Android
# hoặc
fvm flutter build ios  # iOS (macOS only)
```
- [ ] `fvm flutter clean` thành công
- [ ] Build APK hoặc iOS thành công (hoặc có warning chứ không error)
- [ ] Không có lỗi linked to onnxruntime hoặc minSdk

---

## 📁 Project Structure Verification

### Thư Mục & File
```
app_map_limit/
├── .fvm/
│   └── fvm_config.json                  [✓ MUST EXIST]
├── .vscode/
│   ├── settings.json                    [✓ MUST EXIST]
│   └── extensions.json                  [✓ MUST EXIST]
├── android/
│   └── app/
│       └── build.gradle.kts             [✓ minSdk = 24]
├── lib/
│   └── main.dart                        [✓ EXISTS]
├── .gitignore                           [✓ UPDATED]
├── pubspec.yaml                         [✓ WITH DEPENDENCIES]
├── pubspec.lock                         [✓ GENERATED]
├── FVM_SETUP_GUIDE.md                   [✓ NEW]
├── TEAM_WORKFLOW.md                     [✓ NEW]
├── ONNX_RIVERPOD_GUIDE.md              [✓ NEW]
├── setup_fvm.ps1                        [✓ NEW]
└── SETUP_CHECKLIST.md                   [✓ THIS FILE]
```

### Kiểm Tra File Tồn Tại
```powershell
# Tất cả files cần có
$requiredFiles = @(
    ".fvm/fvm_config.json",
    ".vscode/settings.json",
    ".vscode/extensions.json",
    "pubspec.yaml",
    "pubspec.lock"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: $file" -ForegroundColor Red
    }
}
```

---

## 🧪 Functional Testing

### Test 1: Flutter Basic Commands
```powershell
# Command 1: Version check
fvm flutter --version
# Expected: Flutter 3.22.2

# Command 2: Doctor check
fvm flutter doctor -v
# Expected: Mostly ✓ symbols

# Command 3: Pub packages check
fvm flutter pub outdated
# Expected: Lists installed packages
```
- [ ] Tất cả command chạy thành công

### Test 2: Code Analysis
```powershell
# Check code for issues
fvm flutter analyze

# Format code
fvm flutter format lib/
```
- [ ] `fvm flutter analyze` không có error
- [ ] Format code chạy OK

### Test 3: Run on Device/Emulator
```powershell
# List devices
fvm flutter devices

# Run app (chọn device ID)
fvm flutter run -d <device_id>
```
- [ ] Ít nhất 1 device/emulator phát hiện
- [ ] App chạy thành công trên device

### Test 4: Dependencies Load
```powershell
# Tạo file test
# lib/test_imports.dart
import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

# Chạy analyze
fvm flutter analyze
```
- [ ] Imports không có error
- [ ] Không có "unresolved import" warnings

### Test 5: Riverpod Codegen (Optional)
```powershell
# Nếu sử dụng riverpod_generator
fvm flutter pub add -d riverpod_generator build_runner

# Generate code
fvm flutter pub run build_runner build
```
- [ ] Codegen chạy thành công
- [ ] `.g.dart` files được generate

---

## 🎯 Final Verification

### Git Status
```powershell
git status

# Kiểm tra:
# - .fvm/fvm_config.json KHÔNG bị bỏ qua
# - .fvm/flutter_sdk BŚCIE bỏ qua (nếu tồn tại)
# - .gitignore đã update
```
- [ ] Git status giống mong đợi

### Documentation
- [ ] `FVM_SETUP_GUIDE.md` đã read
- [ ] `TEAM_WORKFLOW.md` đã read
- [ ] `ONNX_RIVERPOD_GUIDE.md` đã read

### Team Communication
- [ ] Upload project lên repository
- [ ] Share link `FVM_SETUP_GUIDE.md` với team
- [ ] Thông báo team về FVM requirement

---

## 🚀 Ready to Go!

Nếu tất cả checkbox trên đã checked ✓, bạn sẵn sàng:

### Có Thể Làm
- ✅ Chạy app trên device/emulator
- ✅ Develop features với onnxruntime
- ✅ Sử dụng Riverpod cho state management
- ✅ Build APK/iOS production
- ✅ Chia sẻ project với team (họ chỉ cần chạy `fvm use 3.22.2`)

### Tiếp Theo
1. **Create Model Directory**
   ```powershell
   mkdir -p assets/models
   # Copy .onnx files vào đây
   ```

2. **Update pubspec.yaml - assets**
   ```yaml
   flutter:
     assets:
       - assets/models/
   ```

3. **Start Developing**
   ```powershell
   fvm flutter run
   ```

---

## 📞 Common Issues & Solutions

### ❌ "fvm: command not found"
**Solution:**
```powershell
# Restart PowerShell hoặc thêm vào PATH
dart pub global list
$env:PATH += ";$([System.IO.Path]::Combine($env:APPDATA, 'Pub', 'Cache', 'bin'))"
```

### ❌ "Android SDK minSdk mismatch"
**Solution:**
```powershell
# Verify build.gradle.kts
Get-Content android/app/build.gradle.kts | Select-String "minSdk"
# Should show: minSdk = 24
```

### ❌ "ONNX Runtime won't compile"
**Solution:**
```powershell
# Clean build
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --verbose
```

### ❌ "VS Code Flutter SDK path wrong"
**Solution:**
1. Đóng VS Code
2. Xóa `.dart_tool` nếu cần
3. Mở lại VS Code
4. Command Palette: `Dart: Restart Analysis Server`

---

## 📊 Status Summary

| Item | Status | Notes |
|------|--------|-------|
| FVM | [ ] | Version 3.22.2 |
| Config Files | [ ] | `.fvm`, `.vscode` |
| Android minSdk | [ ] | Set to 24 |
| Dependencies | [ ] | onnxruntime, riverpod |
| Documentation | [ ] | 4 guides created |
| Git Ready | [ ] | `.fvm/flutter_sdk` ignored |
| Team Ready | [ ] | All files committed |

---

**🎉 Congratulations! Your Flutter Project is Ready!**

*Last Updated: November 17, 2025*
