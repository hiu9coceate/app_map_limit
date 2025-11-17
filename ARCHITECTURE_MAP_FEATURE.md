# Hướng dẫn Cấu trúc Code Tính năng Bản đồ

## 📁 Cấu trúc thư mục

```
lib/
└── features/
    └── map/
        ├── data/                  # Tầng dữ liệu (Data Layer)
        │   ├── datasources/
        │   │   └── location_datasource.dart    # Lấy dữ liệu vị trí từ device
        │   └── repositories/
        │       └── location_repository_impl.dart  # Implement repository
        │
        ├── domain/                # Tầng lĩnh vực (Domain Layer)
        │   ├── entities/
        │   │   ├── location.dart           # Model vị trí
        │   │   └── map_marker.dart         # Model marker trên bản đồ
        │   └── repositories/
        │       └── location_repository.dart # Interface repository
        │
        └── presentation/          # Tầng giao diện (Presentation Layer)
            ├── pages/
            │   └── map_page.dart           # Trang chính bản đồ
            ├── providers/
            │   ├── location_provider.dart       # Riverpod providers cho vị trí
            │   └── map_controller_provider.dart # Riverpod providers cho bản đồ
            ├── screens/
            │   └── map_screen.dart         # Screen wrapper
            └── widgets/
                ├── map_widget.dart         # Widget bản đồ chính
                └── location_button.dart    # Button lấy vị trí hiện tại
```

## 🏗️ Kiến trúc Clean Architecture

Dự án sử dụng **Clean Architecture** để tách biệt các phần:

### 1. **Domain Layer** (Lĩnh vực)
- **Mục đích**: Chứa các entity và interface (abstract class)
- **Độc lập**: Không phụ thuộc vào bất kỳ framework nào
- **Files**:
  - `location.dart`: Entity vị trí GPS
  - `map_marker.dart`: Entity marker trên bản đồ
  - `location_repository.dart`: Interface cho lấy dữ liệu vị trí

### 2. **Data Layer** (Dữ liệu)
- **Mục đích**: Xử lý lấy dữ liệu từ các nguồn khác nhau
- **Phụ thuộc**: Implement domain layer
- **Files**:
  - `location_datasource.dart`: Lấy dữ liệu từ device (Geolocator)
  - `location_repository_impl.dart`: Implement LocationRepository

### 3. **Presentation Layer** (Giao diện)
- **Mục đích**: Xử lý UI và logic hiển thị
- **Phụ thuộc**: Phụ thuộc vào data và domain layer
- **Files**:
  - `location_provider.dart`: Riverpod providers cho vị trí
  - `map_controller_provider.dart`: Quản lý state bản đồ
  - `map_page.dart`: Trang chính
  - `map_widget.dart`: Widget bản đồ (hiển thị)
  - `location_button.dart`: Button lấy vị trí

## 📊 Luồng dữ liệu

```
User Action
    ↓
Presentation (UI - map_page.dart)
    ↓
Providers (location_provider.dart, map_controller_provider.dart)
    ↓
Data Layer (location_repository_impl.dart)
    ↓
Data Source (location_datasource.dart - Geolocator)
    ↓
Device GPS/Location Service
```

## 🔧 Các công nghệ sử dụng

- **flutter_map**: Hiển thị bản đồ OpenStreetMap
- **geolocator**: Lấy vị trí GPS từ device
- **flutter_riverpod**: State management
- **latlong2**: Xử lý tọa độ địa lý

## 🚀 Cách sử dụng

### 1. Hiển thị bản đồ
```dart
MapScreen()  // Hiển thị màn hình bản đồ
```

### 2. Lấy vị trí hiện tại
```dart
// Trong ConsumerWidget hoặc ConsumerStatefulWidget:
final location = await ref.read(currentLocationProvider.future);
```

### 3. Theo dõi vị trí theo thời gian thực
```dart
ref.watch(watchLocationProvider)  // Returns AsyncValue<Location>
```

### 4. Quản lý markers
```dart
final mapNotifier = ref.read(mapControllerProvider.notifier);

// Thêm marker
mapNotifier.addMarker(marker);

// Xóa marker
mapNotifier.removeMarker(markerId);

// Cập nhật marker
mapNotifier.updateMarker(updatedMarker);
```

## ✅ Ưu điểm của cấu trúc này

1. **Tách biệt rõ ràng**: Dễ dàng quản lý từng phần
2. **Dễ kiểm thử**: Có thể mock từng layer riêng biệt
3. **Tái sử dụng**: Code không bị lộn xộn
4. **Dễ bảo trì**: Thay đổi một phần không ảnh hưởng phần khác
5. **Scalable**: Dễ thêm tính năng mới

## 🎯 Mở rộng sau này

Bạn có thể dễ dàng thêm:
- Lưu markers vào database
- Tìm kiếm địa điểm gần
- Vẽ polyline/polygon
- Tính khoảng cách
- Import/Export routes
- v.v...

Mỗi tính năng mới chỉ cần thêm files trong các folder tương ứng mà không làm loạn code hiện có.
