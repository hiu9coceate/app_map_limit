import '../entities/location.dart';

/// Abstract repository cho việc lấy dữ liệu vị trí
abstract class LocationRepository {
  /// Lấy vị trí hiện tại của người dùng
  Future<Location> getCurrentLocation();

  /// Theo dõi vị trí người dùng theo thời gian thực
  Stream<Location> watchCurrentLocation();

  /// Kiểm tra quyền truy cập vị trí
  Future<bool> requestLocationPermission();

  /// Kiểm tra xem dịch vụ vị trí có bật không
  Future<bool> isLocationServiceEnabled();
}
