import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location.dart';
import '../services/speed_calculator_service.dart';
import '../services/speed_smoother_service.dart';
import '../services/motion_detector_service.dart';

abstract class LocationDataSource {
  Future<Location> getCurrentLocation();
  Stream<Location> watchCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
}

class LocationDataSourceImpl implements LocationDataSource {
  final SpeedCalculatorService _speedCalculator = SpeedCalculatorService();
  final SpeedSmootherService _speedSmoother = SpeedSmootherService();
  final MotionDetectorService _motionDetector = MotionDetectorService();

  LocationDataSourceImpl() {
    _motionDetector.startListening();
  }

  @override
  Future<Location> getCurrentLocation() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw LocationServiceDisabledException(
          'Dịch vụ định vị bị tắt. Vui lòng bật dịch vụ định vị.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );

    return _convertPositionToLocation(position);
  }

  @override
  Stream<Location> watchCurrentLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
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
  /// Áp dụng tính toán và làm mượt tốc độ
  Location _convertPositionToLocation(Position position) {
    final rawSpeedMps = _speedCalculator.calculateSpeed(position);

    final isMoving = _motionDetector.isMoving;

    final smoothedSpeedMps = _speedSmoother.smoothSpeed(
      rawSpeedMps,
      position.accuracy,
      isMoving,
    );

    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: smoothedSpeedMps,
      timestamp: position.timestamp,
    );
  }

  void dispose() {
    _motionDetector.dispose();
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
