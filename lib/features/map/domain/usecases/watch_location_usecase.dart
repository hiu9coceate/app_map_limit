import '../entities/location.dart';
import '../repositories/location_repository.dart';

/// Use case: Theo dõi vị trí theo thời gian thực
class WatchLocationUseCase {
  final LocationRepository repository;

  WatchLocationUseCase({required this.repository});

  Stream<Location> call() {
    return repository.watchCurrentLocation();
  }
}
