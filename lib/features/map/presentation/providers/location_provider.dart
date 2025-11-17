import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

/// Provider cho LocationDataSource
final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  return LocationDataSourceImpl();
});

/// Provider cho LocationRepository
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return LocationRepositoryImpl(dataSource: dataSource);
});

/// Provider cho vị trí hiện tại của người dùng (một lần)
final currentLocationProvider = FutureProvider<Location>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getCurrentLocation();
});

/// Provider cho theo dõi vị trí hiện tại theo thời gian thực (stream)
final watchLocationProvider = StreamProvider<Location>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.watchCurrentLocation();
});

/// Provider cho kiểm tra trạng thái quyền vị trí
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.requestLocationPermission();
});

/// Provider cho kiểm tra xem dịch vụ vị trí có bật không
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.isLocationServiceEnabled();
});
