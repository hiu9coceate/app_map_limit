import '../repositories/location_repository.dart';

/// Use case: Yêu cầu quyền truy cập vị trí
class RequestLocationPermissionUseCase {
  final LocationRepository repository;

  RequestLocationPermissionUseCase({required this.repository});

  Future<bool> call() async {
    return repository.requestLocationPermission();
  }
}
