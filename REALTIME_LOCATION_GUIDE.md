# 📍 Hướng Dẫn Theo Dõi Vị Trí Thời Gian Thực

## 🎯 Tổng Quan

Ứng dụng đã được cấu hình để theo dõi và hiển thị vị trí người dùng theo thời gian thực giống như Google Maps, bao gồm:

- ✅ Hiển thị vị trí hiện tại với marker có hiệu ứng pulse
- ✅ Tự động cập nhật vị trí khi người dùng di chuyển
- ✅ Tự động di chuyển bản đồ theo vị trí người dùng
- ✅ Hiển thị thông tin vị trí chi tiết (tọa độ, độ chính xác, độ cao)
- ✅ Nút toggle để bật/tắt chế độ theo dõi tự động

## 🚀 Các Tính Năng Chính

### 1. **Marker Vị Trí Hiện Tại**
- Hiển thị dưới dạng chấm tròn màu xanh với viền trắng
- Có hiệu ứng pulse (nhấp nháy) để dễ nhận biết
- Cập nhật vị trí mỗi khi di chuyển ≥ 5 mét

### 2. **Chế Độ Theo Dõi Tự Động (Auto-Follow)**
- Bản đồ tự động di chuyển theo vị trí người dùng
- Tự động tắt khi người dùng kéo/zoom bản đồ
- Có nút toggle để bật/tắt thủ công (góc dưới bên phải)

### 3. **Thông Tin Vị Trí**
Hiển thị ở góc trên cùng bao gồm:
- Vĩ độ (Latitude)
- Kinh độ (Longitude)
- Độ cao (Altitude)
- Độ chính xác GPS (Accuracy)

### 4. **Cấu Hình Real-Time Tracking**
```dart
LocationSettings(
  accuracy: LocationAccuracy.high,  // Độ chính xác cao
  distanceFilter: 5,                // Cập nhật mỗi 5 mét
  timeLimit: Duration(seconds: 10), // Timeout 10 giây
)
```

## 📱 Cách Sử Dụng

### Khởi Động Ứng Dụng
1. Mở ứng dụng
2. Cấp quyền truy cập vị trí khi được yêu cầu
3. Ứng dụng tự động lấy và hiển thị vị trí hiện tại
4. Bản đồ tự động zoom đến vị trí của bạn

### Sử Dụng Nút Điều Khiển

#### Nút "My Location" (Góc dưới bên phải - Nhỏ)
- **Màu xanh**: Đang ở chế độ theo dõi tự động
- **Màu trắng**: Chế độ theo dõi tự động đã tắt
- **Nhấn**: Bật/tắt chế độ theo dõi tự động

#### Nút "Current Location" (Góc dưới bên phải - Lớn)
- **Nhấn**: Lấy vị trí hiện tại và di chuyển bản đồ đến đó

### Tương Tác Với Bản Đồ
- **Kéo bản đồ**: Tự động tắt chế độ theo dõi
- **Zoom in/out**: Không ảnh hưởng đến chế độ theo dõi
- **Tap vào bản đồ**: Tắt chế độ theo dõi

## 🔧 Cấu Hình Quyền

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí của bạn để hiển thị vị trí hiện tại trên bản đồ</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí của bạn để theo dõi vị trí theo thời gian thực</string>
```

## 🎨 Tùy Chỉnh

### Thay Đổi Khoảng Cách Cập Nhật
Trong `lib/features/map/data/datasources/location_datasource.dart`:
```dart
distanceFilter: 5, // Thay đổi số mét ở đây
```

### Thay Đổi Độ Chính Xác GPS
```dart
accuracy: LocationAccuracy.high, // Có thể dùng: low, medium, high, best
```

### Tùy Chỉnh Hiệu Ứng Pulse
Trong `lib/features/map/presentation/widgets/map_widget.dart`:
```dart
duration: const Duration(milliseconds: 1500), // Tốc độ pulse
Tween<double>(begin: 1.0, end: 1.5)          // Kích thước pulse
```

## 🐛 Xử Lý Lỗi

### Lỗi: "Dịch vụ định vị bị tắt"
**Giải pháp**: Bật GPS/Location Services trên thiết bị

### Lỗi: "Không có quyền truy cập vị trí"
**Giải pháp**: 
1. Vào Settings > Apps > [Tên App] > Permissions
2. Cấp quyền Location

### Vị trí không cập nhật
**Kiểm tra**:
1. GPS đã bật chưa?
2. Có ở ngoài trời hoặc gần cửa sổ không?
3. Kiểm tra `distanceFilter` có quá lớn không?

## 📊 Luồng Dữ Liệu

```
GPS Device
    ↓
Geolocator.getPositionStream()
    ↓
LocationDataSource (với LocationSettings)
    ↓
LocationRepository
    ↓
watchLocationProvider (StreamProvider)
    ↓
MapPage (ref.listen)
    ↓
MapNotifier.setCurrentLocation()
    ↓
MapState.currentLocation
    ↓
MapWidget rebuild → Hiển thị marker mới
    ↓
Auto-follow → Di chuyển bản đồ
```

## 🎯 Best Practices

1. **Tiết kiệm pin**: Tăng `distanceFilter` nếu không cần độ chính xác cao
2. **Độ chính xác**: Dùng `LocationAccuracy.high` cho tracking chính xác
3. **UX**: Tự động tắt follow khi người dùng tương tác với bản đồ
4. **Performance**: Chỉ cập nhật khi vị trí thay đổi đáng kể

## 📝 Ghi Chú

- Stream vị trí chạy liên tục khi app mở
- Marker có animation pulse để dễ nhận biết
- Thông tin vị trí cập nhật real-time
- Bản đồ tự động theo dõi vị trí người dùng

