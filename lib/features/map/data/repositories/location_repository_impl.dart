import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

/// Implementation của LocationRepository
class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl({required this.dataSource});

  @override
  Future<Location> getCurrentLocation() async {
    // Kiểm tra quyền trước khi lấy vị trí
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw LocationPermissionDeniedException(
          'Không có quyền truy cập vị trí của người dùng');
    }

    return dataSource.getCurrentLocation();
  }

  @override
  Stream<Location> watchCurrentLocation() {
    return dataSource.watchCurrentLocation();
  }

  @override
  Future<bool> requestLocationPermission() {
    return dataSource.requestLocationPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return dataSource.isLocationServiceEnabled();
  }
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}
