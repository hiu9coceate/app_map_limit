# 📋 Tóm tắt Cấu trúc Code - Tính năng Bản đồ

## 📁 Cây thư mục đầy đủ

```
lib/
└── features/
    └── map/
        ├── core/                          # Các tiện ích chung
        │   ├── constants/
        │   │   ├── map_constants.dart         # Hằng số (zoom, tọa độ mặc định, etc)
        │   │   └── map_error_messages.dart   # Thông báo lỗi
        │   └── exceptions/
        │       └── map_exceptions.dart       # Các lớp exception custom
        │
        ├── data/                          # Tầng dữ liệu
        │   ├── datasources/
        │   │   └── location_datasource.dart  # Giao tiếp với Geolocator
        │   └── repositories/
        │       └── location_repository_impl.dart
        │
        ├── domain/                        # Tầng lĩnh vực (Business Logic)
        │   ├── entities/
        │   │   ├── location.dart              # Model vị trí GPS
        │   │   └── map_marker.dart            # Model marker
        │   ├── extensions/
        │   │   └── location_extensions.dart   # Utilities cho Location
        │   ├── repositories/
        │   │   └── location_repository.dart   # Interface repository
        │   └── usecases/
        │       ├── get_current_location_usecase.dart
        │       ├── watch_location_usecase.dart
        │       ├── request_location_permission_usecase.dart
        │       └── check_location_service_usecase.dart
        │
        └── presentation/                  # Tầng giao diện
            ├── pages/
            │   └── map_page.dart              # Trang chính
            ├── providers/
            │   ├── location_provider.dart        # Riverpod providers
            │   └── map_controller_provider.dart  # State notifier
            ├── screens/
            │   └── map_screen.dart            # Screen wrapper
            └── widgets/
                ├── map_widget.dart            # Widget bản đồ
                └── location_button.dart       # Button FAB
```

## 📝 Chi tiết các File

### **core/** - Tiện ích chung
| File | Mục đích |
|------|---------|
| `map_constants.dart` | Định nghĩa hằng số (zoom, tọa độ mặc định) |
| `map_error_messages.dart` | Thông báo lỗi được đa ngôn ngữ hóa |
| `map_exceptions.dart` | Các lớp exception custom |

### **domain/** - Tầng Business Logic (độc lập)
| File | Mục đích |
|------|---------|
| `entities/location.dart` | Entity đơn giản với lat/lng |
| `entities/map_marker.dart` | Entity marker |
| `repositories/location_repository.dart` | Interface (abstract) |
| `extensions/location_extensions.dart` | Methods mở rộng (distance, URLs, etc) |
| `usecases/*.dart` | Các use case riêng biệt |

### **data/** - Tầng dữ liệu
| File | Mục đích |
|------|---------|
| `datasources/location_datasource.dart` | Sử dụng Geolocator package |
| `repositories/location_repository_impl.dart` | Implement LocationRepository |

### **presentation/** - Tầng UI
| File | Mục đích |
|------|---------|
| `providers/location_provider.dart` | Riverpod providers |
| `providers/map_controller_provider.dart` | State management |
| `pages/map_page.dart` | Logic trang map |
| `widgets/map_widget.dart` | Widget bản đồ (hiển thị) |
| `widgets/location_button.dart` | Button lấy vị trí |
| `screens/map_screen.dart` | Wrapper ProviderScope |

## 🔄 Luồng dữ liệu

```
User tap button
    ↓
location_button.dart (ConsumerWidget)
    ↓
ref.read(currentLocationProvider.future)
    ↓
location_provider.dart (FutureProvider)
    ↓
LocationRepository.getCurrentLocation()
    ↓
LocationDataSourceImpl.getCurrentLocation()
    ↓
Geolocator.getCurrentPosition()
    ↓
Device GPS (Android/iOS)
    ↓
Location entity
    ↓
mapControllerProvider.notifier.setCurrentLocation()
    ↓
State updated → map_widget.dart rebuild
```

## 🎯 Các phần code được tách riêng

### **Phần 1: Lấy dữ liệu vị trí**
- **Tập trung tại**: `data/datasources/location_datasource.dart`
- **Chỉnh sửa**: Thay đổi logic lấy vị trí ở đây

### **Phần 2: Xử lý quyền & quy tắc business**
- **Tập trung tại**: `data/repositories/location_repository_impl.dart`
- **Chỉnh sửa**: Thêm logic kiểm tra, xác thực ở đây

### **Phần 3: Model & Entity**
- **Tập trung tại**: `domain/entities/`
- **Chỉnh sửa**: Cấu trúc dữ liệu

### **Phần 4: Giao diện**
- **Tập trung tại**: `presentation/widgets/map_widget.dart`
- **Chỉnh sửa**: Thiết kế, màu sắc, layout

### **Phần 5: State Management**
- **Tập trung tại**: `presentation/providers/map_controller_provider.dart`
- **Chỉnh sửa**: Logic state, actions

### **Phần 6: Màn hình chính**
- **Tập trung tại**: `presentation/pages/map_page.dart`
- **Chỉnh sửa**: Cấu trúc trang, toolbar, FAB

## ✅ Lợi ích của cấu trúc này

1. **Tách biệt rõ ràng**: Mỗi phần có trách nhiệm riêng
2. **Dễ test**: Có thể mock từng layer
3. **Dễ bảo trì**: Tìm lỗi nhanh hơn
4. **Tái sử dụng**: Components có thể dùng lại
5. **Dễ mở rộng**: Thêm tính năng mới không ảnh hưởng cũ

## 🚀 Cách thêm tính năng mới

### Ví dụ: Thêm tính năng "Lưu Marker"

1. **Domain (logic)**: Tạo `domain/entities/saved_marker.dart`
2. **Domain (interface)**: Thêm method vào `domain/repositories/marker_repository.dart`
3. **Data**: Tạo `data/datasources/marker_datasource.dart` (SQLite/Firebase)
4. **Data**: Implement `data/repositories/marker_repository_impl.dart`
5. **Presentation**: Tạo `presentation/providers/marker_provider.dart`
6. **Presentation**: Thêm widget `presentation/widgets/save_marker_button.dart`

Không cần chỉnh sửa code cũ!

## 📚 Dependencies

- `flutter_map`: Hiển thị bản đồ
- `geolocator`: Lấy GPS
- `flutter_riverpod`: State management
- `latlong2`: Xử lý tọa độ
