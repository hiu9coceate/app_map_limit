import 'dart:async';
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
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw LocationServiceDisabledException(
          'Dịch vụ định vị bị tắt. Vui lòng bật dịch vụ định vị.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    return _convertPositionToLocation(position);
  }

  @override
  Stream<Location> watchCurrentLocation() {
    // Cấu hình CHÍNH XÁC như best practices
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Tốt nhất cho navigation/speed
      distanceFilter: 0, // Cập nhật ngay lập tức, không lọc khoảng cách
      // BỎ timeLimit để tránh TimeoutException
    );

    // Trả về stream trực tiếp từ Geolocator
    // KHÔNG tính toán thủ công, dùng position.speed có sẵn
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

  /// Chuyển đổi Position sang Location
  /// SỬ DỤNG position.speed CÓ SẴN từ GPS/Doppler
  Location _convertPositionToLocation(Position position) {
    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      // QUAN TRỌNG: Dùng speed từ GPS, đã được tính bằng Doppler
      speed: position.speed >= 0 ? position.speed : 0.0,
      timestamp: position.timestamp,
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
