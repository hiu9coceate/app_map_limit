import '../repositories/location_repository.dart';

/// Use case: Kiểm tra xem dịch vụ vị trí có bật không
class CheckLocationServiceUseCase {
  final LocationRepository repository;

  CheckLocationServiceUseCase({required this.repository});

  Future<bool> call() async {
    return repository.isLocationServiceEnabled();
  }
}
