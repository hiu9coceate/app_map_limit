import 'package:geolocator/geolocator.dart';
import 'moving_average_service.dart';

class SpeedCalculatorService {
  Position? _previousPosition;
  DateTime? _previousTime;
  final MovingAverageService _movingAverage = MovingAverageService();

  double calculateSpeed(Position currentPosition) {
    final osSpeed = currentPosition.speed;

    if (osSpeed >= 0 && osSpeed < 100) {
      _previousPosition = currentPosition;
      _previousTime = currentPosition.timestamp;
      return osSpeed;
    }

    if (_previousPosition == null || _previousTime == null) {
      _previousPosition = currentPosition;
      _previousTime = currentPosition.timestamp;
      return 0.0;
    }

    final currentTime = currentPosition.timestamp;
    final timeDiffSeconds =
        currentTime.difference(_previousTime!).inMilliseconds / 1000.0;

    if (timeDiffSeconds < 0.05) {
      return osSpeed >= 0 ? osSpeed : 0.0;
    }

    final averageSpeed = _movingAverage.calculateAverageSpeed(currentPosition);

    _previousPosition = currentPosition;
    _previousTime = currentTime;

    return averageSpeed;
  }

  void reset() {
    _previousPosition = null;
    _previousTime = null;
    _movingAverage.reset();
  }
}
