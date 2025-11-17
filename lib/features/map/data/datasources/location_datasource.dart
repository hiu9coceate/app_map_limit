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
    return Geolocator.getPositionStream().map(_convertPositionToLocation);
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
