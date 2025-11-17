# ⚡ FVM + ONNX Runtime - Quick Reference (Bảng Ghi Chép Nhanh)

## 🎯 Các Lệnh Hay Dùng

### Khởi Tạo (Lần Đầu Tiên)
```powershell
# 1. Cài FVM
dart pub global activate fvm

# 2. Cài Flutter 3.22.2
fvm install 3.22.2
fvm use 3.22.2

# 3. Cài dependencies
fvm flutter pub add onnxruntime flutter_riverpod
fvm flutter pub get

# 4. Verify
fvm flutter --version   # Should show 3.22.2
fvm flutter doctor      # Check all is OK
```

### Chạy App
```powershell
# List devices
fvm flutter devices

# Run on device
fvm flutter run

# Run release build
fvm flutter run --release

# Run with specific device
fvm flutter run -d <device_id>
```

### Build Production
```powershell
# Android APK
fvm flutter build apk

# Android App Bundle
fvm flutter build appbundle

# iOS (macOS only)
fvm flutter build ios

# Web
fvm flutter build web
```

### Development
```powershell
# Format code
fvm flutter format lib/

# Analyze code
fvm flutter analyze

# Run tests
fvm flutter test

# Clean build cache
fvm flutter clean

# Get new dependencies
fvm flutter pub get

# Update dependencies
fvm flutter pub upgrade
```

---

## 📁 File Structure Quick View

```
.fvm/
  └── fvm_config.json          ← Pin version here

.vscode/
  ├── settings.json            ← VS Code config
  └── extensions.json          ← Extensions recommendation

android/app/
  └── build.gradle.kts         ← minSdk = 24 (for onnxruntime)

lib/
  ├── main.dart
  ├── config/                  ← ONNX config
  ├── models/                  ← Data models
  ├── services/                ← ONNX service
  ├── providers/               ← Riverpod providers
  └── screens/                 ← UI screens

assets/
  └── models/                  ← Your .onnx files

pubspec.yaml                   ← Dependencies
```

---

## 🚀 Workflow Típico

### Para Nuevo Desarrollador en el Team
```powershell
1. git clone <repo>
2. cd app_map_limit
3. fvm use 3.22.2
4. fvm flutter pub get
5. code .
6. fvm flutter run
```

### Para Cambios en Dependencias
```powershell
1. fvm flutter pub add <package>     # Agregar paquete
2. fvm flutter pub remove <package>  # Remover paquete
3. git add pubspec.*
4. git commit -m "Update dependencies"
```

---

## 🔧 Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| `fvm: command not found` | `dart pub global activate fvm` |
| Build error on Android | `fvm flutter clean && fvm flutter pub get` |
| VS Code can't find Flutter | Close VS Code + restart |
| Old Flutter version running | `fvm use 3.22.2` + verify with `fvm flutter --version` |
| Permission denied on macOS | `chmod +x setup_fvm.ps1` |

---

## 📚 Arquivos de Documentación

| Archivo | Propósito |
|---------|-----------|
| `FVM_SETUP_GUIDE.md` | Setup detallado para todos |
| `TEAM_WORKFLOW.md` | Workflow y comandos para el equipo |
| `ONNX_RIVERPOD_GUIDE.md` | Guía completa de ONNX + Riverpod |
| `SETUP_CHECKLIST.md` | Checklist de verificación |
| `QUICK_REFERENCE.md` | Este archivo |

---

## 💾 pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  onnxruntime: ^1.16.0          ← ONNX inference
  flutter_riverpod: ^2.4.0      ← State management
  riverpod: ^2.4.0              ← Pure Dart riverpod

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.0          ← For code generation
  riverpod_generator: ^2.3.0    ← Riverpod codegen
```

---

## 🎯 Configuración de Android

**En `android/app/build.gradle.kts`:**
```gradle-kotlin-dsl
defaultConfig {
    minSdk = 24              # ← Required for onnxruntime (API 24+)
    targetSdk = flutter.targetSdkVersion
    // ...
}
```

---

## 📱 Device Commands

```powershell
# Ver dispositivos conectados
fvm flutter devices

# Ver emuladores disponibles
flutter emulators

# Lanzar emulador
flutter emulators --launch <emulator_name>

# Instalar app en dispositivo
fvm flutter install

# Desinstalar app
fvm flutter uninstall

# Ver logs
fvm flutter logs

# Ver logs con grep
fvm flutter logs | Select-String "keyword"
```

---

## 🧪 Testing Commands

```powershell
# Ejecutar todos los tests
fvm flutter test

# Test specific file
fvm flutter test test/widget_test.dart

# Test con coverage
fvm flutter test --coverage

# Generate coverage report
format_coverage --lcov --in=coverage/lcov.info --out=coverage/lcov-formatted.info
```

---

## 🔍 FVM Específico

```powershell
# Ver versiones instaladas
fvm list

# Ver versiones disponibles
fvm releases

# Usar versión específica
fvm use 3.22.2

# Remover versión
fvm remove 3.22.1

# Ver ruta SDK actual
fvm which flutter
```

---

## 💡 Riverpod Quick Syntax

### Provider Básico
```dart
final helloProvider = Provider((ref) => 'Hello');
```

### FutureProvider
```dart
final dataProvider = FutureProvider((ref) async {
  return await fetchData();
});
```

### StateProvider
```dart
final countProvider = StateProvider((ref) => 0);

// In widget
count.read(countProvider);                    // Read
ref.watch(countProvider);                     // Watch (rebuild)
ref.read(countProvider.notifier).state = 5;   // Update
```

### StateNotifierProvider
```dart
class CountNotifier extends StateNotifier<int> {
  CountNotifier() : super(0);
  void increment() => state++;
}

final countProvider = StateNotifierProvider((ref) => CountNotifier());
```

---

## 🌐 ONNX Quick Example

### Basic Inference
```dart
import 'package:onnxruntime/onnxruntime.dart';

final input = [[[[1.0, 2.0, 3.0]]]];  // Reshape to model input
final session = OrtSession.fromAsset('assets/models/model.onnx');
final output = session.run(null, {'input': input});
print(output);
```

### With Riverpod
```dart
final modelProvider = FutureProvider((ref) async {
  return OrtSession.fromAsset('assets/models/model.onnx');
});

final inferenceProvider = FutureProvider.family((ref, input) async {
  final session = await ref.watch(modelProvider);
  return session.run(null, {'input': input});
});
```

---

## 🎨 VS Code Extensions

Recomendadas automáticamente:
- ✅ Dart
- ✅ Flutter  
- ✅ Flutter Tree View
- ✅ Python (for scripts)

Manual install si es necesario:
```powershell
# Abrir VS Code Command Palette
Ctrl+Shift+P

# Extensions: Install Extensions
# Search y instala: 
#   - Dart
#   - Flutter
```

---

## 📊 Performance Tips

1. **Use Release Build para testing**
   ```powershell
   fvm flutter run --release
   ```

2. **Enable profiling**
   ```powershell
   fvm flutter run --profile
   ```

3. **Check startup time**
   ```powershell
   fvm flutter run -v | Select-String "Started"
   ```

---

## 🔐 Git Checklist

```powershell
# Verify .gitignore
Get-Content .gitignore | Select-String ".fvm"

# Should show:
# .fvm/flutter_sdk/    ← SDK ignored
# !.fvm/               ← Config folder tracked
# !.fvm/fvm_config.json ← Config file tracked

# Commit files
git add .fvm/fvm_config.json
git add .vscode/
git add pubspec.*
git commit -m "Setup FVM and ONNX runtime"
```

---

## 📞 Get Help

```powershell
# Flutter help
fvm flutter --help

# Specific command help
fvm flutter run --help

# Package help
fvm flutter pub --help

# FVM help
fvm --help
```

---

## 🆚 Comparación: Con FVM vs Sin FVM

| Aspecto | Sin FVM | Con FVM |
|--------|---------|---------|
| Versión Flutter | Mutable | Fixed ✓ |
| Team Consistency | ❌ Problems | ✅ All same |
| CI/CD | ❌ Inconsistent | ✅ Reproducible |
| Setup Time | Variable | Consistent |
| Update Control | Manual | Controlled |

---

## 🎯 Next Steps Después del Setup

1. [ ] Crear carpeta `assets/models/`
2. [ ] Copiar `.onnx` files
3. [ ] Crear `OnnxService`
4. [ ] Setup Riverpod providers
5. [ ] Build UI con inference
6. [ ] Test en device real
7. [ ] Optimize performance
8. [ ] Deploy to production

---

**⏱️ Cheat Sheet Version: 1.0**
*Última Actualización: November 17, 2025*

*Guarda este archivo para referencia rápida! 📌*
