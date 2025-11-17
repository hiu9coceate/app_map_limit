# 📚 Hướng dẫn sử dụng tính năng Map

## 1. Cấu hình Quyền truy cập

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí của bạn để hiển thị trên bản đồ</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Ứng dụng cần quyền truy cập vị trí</string>
```

## 2. Các Providers (Riverpod)

### a) Lấy vị trí một lần
```dart
final location = await ref.read(currentLocationProvider.future);
print('Vị trí: ${location.latitude}, ${location.longitude}');
```

### b) Theo dõi vị trí thay đổi theo thời gian thực
```dart
ref.watch(watchLocationProvider).whenData((location) {
  print('Vị trí cập nhật: $location');
});
```

### c) Kiểm tra quyền
```dart
final hasPermission = await ref.read(locationPermissionProvider.future);
if (!hasPermission) {
  print('Không có quyền truy cập vị trí');
}
```

## 3. Quản lý Markers

### Thêm marker
```dart
final mapNotifier = ref.read(mapControllerProvider.notifier);

final newMarker = MapMarker(
  id: 'marker_1',
  location: Location(latitude: 10.8231, longitude: 106.6797),
  title: 'TP. Hồ Chí Minh',
  description: 'Thành phố Hồ Chí Minh',
);

mapNotifier.addMarker(newMarker);
```

### Xóa marker
```dart
mapNotifier.removeMarker('marker_1');
```

### Cập nhật marker
```dart
final updatedMarker = newMarker.copyWith(
  title: 'Sài Gòn',
);
mapNotifier.updateMarker(updatedMarker);
```

### Xóa tất cả markers
```dart
mapNotifier.clearMarkers();
```

## 4. Xử lý Lỗi

```dart
final mapState = ref.watch(mapControllerProvider);

if (mapState.errorMessage != null) {
  print('Lỗi: ${mapState.errorMessage}');
}
```

### Các loại lỗi có thể xảy ra:
- `LocationServiceDisabledException`: Dịch vụ định vị bị tắt
- `LocationPermissionDeniedException`: Không có quyền truy cập vị trí

## 5. Ví dụ Hoàn chỉnh: Thêm Marker tại vị trí hiện tại

```dart
class AddMarkerButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _addMarkerAtCurrentLocation(context, ref),
      child: const Icon(Icons.add_location),
    );
  }

  Future<void> _addMarkerAtCurrentLocation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Lấy vị trí hiện tại
      final location = await ref.read(currentLocationProvider.future);
      
      // Tạo marker
      final marker = MapMarker(
        id: DateTime.now().toString(),
        location: location,
        title: 'Vị trí của bạn',
        description: 'Tọa độ: ${location.latitude}, ${location.longitude}',
      );
      
      // Thêm vào bản đồ
      ref.read(mapControllerProvider.notifier).addMarker(marker);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm marker')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}
```

## 6. Trạng thái Loading

```dart
final mapState = ref.watch(mapControllerProvider);

if (mapState.isLoading) {
  return const CircularProgressIndicator();
}
```

## 7. Thay đổi mức Zoom

```dart
ref.read(mapControllerProvider.notifier).setZoom(15.0);
```

## 8. Cấu trúc dữ liệu Location

```dart
Location(
  latitude: 10.8231,      // Vĩ độ
  longitude: 106.6797,    // Kinh độ
  accuracy: 5.5,          // Độ chính xác (mét)
  altitude: 10.0,         // Độ cao (mét)
)
```

## 9. Cấu trúc dữ liệu MapMarker

```dart
MapMarker(
  id: 'unique_id',                    // ID duy nhất
  location: Location(...),             // Vị trí trên bản đồ
  title: 'Tiêu đề',                   // Tiêu đề marker
  description: 'Mô tả',               // Mô tả chi tiết
  iconUrl: 'https://...',             // URL icon (tùy chọn)
)
```

## 10. Tips & Tricks

### Di chuyển bản đồ đến vị trí
```dart
// Trong MapWidget context:
final mapKey = GlobalKey<State>();
mapKey.currentState?.animateTo(location, zoom: 15.0);
```

### Lắng nghe thay đổi vị trí
```dart
ref.listen(watchLocationProvider, (previous, next) {
  next.whenData((location) {
    print('Vị trí mới: $location');
  });
});
```

### Kiểm tra dịch vụ vị trí
```dart
final isEnabled = await ref.read(locationServiceEnabledProvider.future);
if (!isEnabled) {
  print('Vui lòng bật dịch vụ định vị');
}
```

## 🐛 Debugging

Để debug vị trí:

```dart
import 'package:flutter/foundation.dart';

void _debugLocation(Location location) {
  if (kDebugMode) {
    print('[Location Debug]');
    print('Latitude: ${location.latitude}');
    print('Longitude: ${location.longitude}');
    print('Accuracy: ${location.accuracy} meters');
    print('Altitude: ${location.altitude} meters');
  }
}
```
