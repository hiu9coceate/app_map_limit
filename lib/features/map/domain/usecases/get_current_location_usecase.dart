import '../entities/location.dart';
import '../repositories/location_repository.dart';

/// Use case: Lấy vị trí hiện tại
class GetCurrentLocationUseCase {
  final LocationRepository repository;

  GetCurrentLocationUseCase({required this.repository});

  Future<Location> call() async {
    return repository.getCurrentLocation();
  }
}
