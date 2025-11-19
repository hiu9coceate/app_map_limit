import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location.dart';
import '../services/speed_filter_service.dart';

/// Datasource cho việc lấy dữ liệu vị trí từ device
abstract class LocationDataSource {
  Future<Location> getCurrentLocation();
  Stream<Location> watchCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
}

/// Implementation của LocationDataSource sử dụng Geolocator
class LocationDataSourceImpl implements LocationDataSource {
  final SpeedFilterService _speedFilter = SpeedFilterService();

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
    // Cấu hình tối ưu cho real-time tracking
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Không lọc khoảng cách - nhận mọi update
      // Không set timeLimit để tránh timeout
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => _convertPositionToLocation(position));
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
  /// Áp dụng filter
  Location _convertPositionToLocation(Position position) {
    final rawSpeed = position.speed >= 0 ? position.speed : 0.0;
    final timestamp = position.timestamp;

    // Áp dụng filter
    final filteredSpeed = _speedFilter.filterSpeed(
      rawSpeed,
      position.accuracy,
      timestamp,
    );

    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: filteredSpeed,
      timestamp: timestamp,
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
