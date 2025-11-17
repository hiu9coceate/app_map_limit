# app_map_limit 🚀

A Flutter project with local AI inference (ONNX Runtime) and Riverpod state management.

---

## ⚡ Quick Start

### For New Developers
```bash
# 1. Clone & enter project
git clone <repo>
cd app_map_limit

# 2. Setup FVM & dependencies
fvm use 3.22.2
fvm flutter pub get

# 3. Run
fvm flutter run
```

### For First Time Setup (Team Lead)
```bash
# Run automated setup
.\setup_fvm.ps1

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
