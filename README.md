# app_map_limit 🚀

A Flutter project with local AI inference (ONNX Runtime) and Riverpod state management.

---

## ⚡ Quick Start

### cách chạy project
```bash
# 1. Clone repo
git clone https://github.com/hiu9coceate/app_map_limit.git
cd app_map_limit

# 2. Cấu hình tên + email (một lần)
git config user.name "Tên của github"
git config user.email "email@example.com"

# 3. Setup FVM & dependencies
dart pub global activate fvm
fvm use 3.22.2


# 3. Run
fvm flutter run
```

### cách push code
```bash
# 1. pull code mới về trước khi code ( luôn luôn và pull code lun lun ở nhánh main )
git checkout main   #lệnh chở về nhánh main
git pull origin main    #lệnh pull code mới nhất về

# 2. tạo nhánh khác để bắt đầu code ( lưu ý: tạo nhánh khác trước khi code nếu không code xong sẽ không push được )
git checkout -b 'tên nhánh' # ví dụ làm add thêm chức năng xem bản đồ thì đặt là xemMap hoặc addMap nhớ thêm tên phân loại nếu là chức năng mới thì là: feature/ , còn nếu là fix bug thì là bug/ ví dụ: git checkout -b 'feature/addMapp'

# 3. add và commit sau khi code xong
git add .
git commit -m 'tên chức năng hoặc tên bug'


# 3. pull và push lên code mới ( đứng tại nhánh vưa code xong thực hiện các lệnh dưới đây )
git pull origin main
git push -u origin tên nhánh hiện tại

# 4. sau khi push xong trở lại nhánh main bắt buộc luôn luôn chở lại nhánh main sau khi push xong
git checkout main

```

# Or read the guides
# - Start: DOCUMENTATION_INDEX.md
# - Setup: FVM_SETUP_GUIDE.md
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[DOCUMENTATION_INDEX.md](./DOCUMENTATION_INDEX.md)** | 📖 Where to start - Navigation guide |
| **[COMPLETION_REPORT.md](./COMPLETION_REPORT.md)** | 📋 What was setup & configured |
| **[PROJECT_SETUP_SUMMARY.md](./PROJECT_SETUP_SUMMARY.md)** | 📌 Overview & getting started |
| **[FVM_SETUP_GUIDE.md](./FVM_SETUP_GUIDE.md)** | 🔧 Detailed setup instructions |
| **[TEAM_WORKFLOW.md](./TEAM_WORKFLOW.md)** | 👥 Team operations & workflow |
| **[ONNX_RIVERPOD_GUIDE.md](./ONNX_RIVERPOD_GUIDE.md)** | 🤖 Implementation guide + code examples |
| **[SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** | ✅ Verification & testing |
| **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** | ⚡ Command cheat sheet (bookmark this!) |

---

## 🎯 Key Technologies

- **Flutter:** 3.22.2 (pinned with FVM)
- **ONNX Runtime:** Local AI inference on device
- **Riverpod:** State management
- **FVM:** Flutter Version Management
- **Android minSdk:** 24 (ONNX requirement)

---

## 🚀 Common Commands

```powershell
# Run app
fvm flutter run

# Format code
fvm flutter format lib/

# Analyze
fvm flutter analyze

# Build APK
fvm flutter build apk

# Clean
fvm flutter clean
```

**→ More commands in:** [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md)

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── config/                      # Configuration
├── models/                      # Data models
├── services/                    # ONNX service
├── providers/                   # Riverpod providers
└── screens/                     # UI screens

assets/
└── models/                      # .onnx files (add your models here)
```

---

## 🤖 ONNX Runtime Usage

### Basic Setup
```dart
import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Load model
final session = OrtSession.fromAsset('assets/models/model.onnx');

// Run inference
final output = session.run(null, {'input': inputData});
```

**→ Complete guide in:** [`ONNX_RIVERPOD_GUIDE.md`](./ONNX_RIVERPOD_GUIDE.md)

---

## 👥 For Team Members

1. **New to project?** Read: [`TEAM_WORKFLOW.md`](./TEAM_WORKFLOW.md)
2. **Need quick commands?** See: [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md)
3. **Ready to code?** Read: [`ONNX_RIVERPOD_GUIDE.md`](./ONNX_RIVERPOD_GUIDE.md)
4. **Something broken?** Check: [`FVM_SETUP_GUIDE.md`](./FVM_SETUP_GUIDE.md)

---

## ✅ Status

- ✅ FVM configured for Flutter 3.22.2
- ✅ ONNX Runtime ready
- ✅ Riverpod setup complete
- ✅ Android minSdk = 24
- ✅ VS Code auto-configured
- ✅ Documentation complete
- ✅ Setup automation script ready

**→ Details in:** [`COMPLETION_REPORT.md`](./COMPLETION_REPORT.md)

---

## 🔗 Resources

- [FVM Documentation](https://fvm.app/)
- [ONNX Runtime Flutter](https://pub.dev/packages/onnxruntime)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Official](https://flutter.dev/)

---

## 📞 Getting Help

1. **Check docs first:** Use [`DOCUMENTATION_INDEX.md`](./DOCUMENTATION_INDEX.md) to find what you need
2. **Quick reference:** [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md)
3. **Troubleshooting:** [`FVM_SETUP_GUIDE.md`](./FVM_SETUP_GUIDE.md)
4. **Deep dive:** [`ONNX_RIVERPOD_GUIDE.md`](./ONNX_RIVERPOD_GUIDE.md)

---

## 📋 Pre-Commit Checklist

- [ ] `fvm flutter format lib/`
- [ ] `fvm flutter analyze`
- [ ] `fvm flutter test`
- [ ] No uncommitted config in `.fvm/flutter_sdk`

---

**Created:** November 17, 2025  
**Status:** Production Ready ✅

---

*Sẵn sàng phát triển ứng dụng AI với Flutter! 🎉*
