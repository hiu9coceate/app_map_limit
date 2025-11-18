import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location.dart';

/// Datasource cho việc lấy dữ liệu vị trí từ device
abstract class LocationDataSource {
  Future<Location> getCurrentLocation();
  Stream<Location> watchCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
}

/// Implementation của LocationDataSource sử dụng Geolocator
class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Location> getCurrentLocation() async {
    // Kiểm tra xem dịch vụ vị trí có bật không
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw LocationServiceDisabledException(
          'Dịch vụ định vị bị tắt. Vui lòng bật dịch vụ định vị.');
    }

    // Lấy vị trí hiện tại
    final position = await Geolocator.getCurrentPosition();

    return _convertPositionToLocation(position);
  }

  @override
  Stream<Location> watchCurrentLocation() {
    // Cấu hình cho real-time tracking như Google Maps
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Độ chính xác cao
      distanceFilter: 5, // Cập nhật mỗi khi di chuyển 5 mét
      timeLimit: Duration(seconds: 10), // Timeout 10 giây
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map(_convertPositionToLocation);
  }

  @override
  Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Chuyển đổi Position từ Geolocator thành Location entity
  Location _convertPositionToLocation(Position position) {
    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed, // Tốc độ di chuyển (m/s)
    );
  }
}

/// Exception khi dịch vụ định vị bị tắt
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

/// Exception khi từ chối quyền truy cập vị trí
class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}
