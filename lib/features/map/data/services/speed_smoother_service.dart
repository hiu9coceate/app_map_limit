import 'kalman_filter_service.dart';

class SpeedSmootherService {
  static const double minSpeedThresholdMps = 0.3;
  static const double maxAccuracyThresholdMeters = 20.0;
  static const double mediumAccuracyThresholdMeters = 10.0;

  final KalmanFilterService _kalmanFilter = KalmanFilterService();
  double _smoothedSpeed = 0.0;
  int _lowSpeedCounter = 0;
  int _zeroSpeedCounter = 0;

  double smoothSpeed(
    double rawSpeedMps,
    double? accuracyMeters,
    bool isMoving,
  ) {
    if (accuracyMeters != null && accuracyMeters > maxAccuracyThresholdMeters) {
      _zeroSpeedCounter++;
      if (_zeroSpeedCounter >= 3) {
        _smoothedSpeed = 0.0;
        _kalmanFilter.reset();
        return 0.0;
      }
      return _smoothedSpeed;
    }

    if (accuracyMeters != null &&
        accuracyMeters > mediumAccuracyThresholdMeters) {
      _kalmanFilter.increaseMeasurementNoise();
    } else {
      _kalmanFilter.resetMeasurementNoise();
    }

    if (rawSpeedMps < minSpeedThresholdMps) {
      _lowSpeedCounter++;
      _zeroSpeedCounter++;
      if (_lowSpeedCounter >= 3 && _zeroSpeedCounter >= 3) {
        _smoothedSpeed = 0.0;
        _kalmanFilter.reset();
        _lowSpeedCounter = 0;
        _zeroSpeedCounter = 0;
        return 0.0;
      }
      return _smoothedSpeed;
    }

    _lowSpeedCounter = 0;
    _zeroSpeedCounter = 0;

    _smoothedSpeed = _kalmanFilter.filter(rawSpeedMps);

    return _smoothedSpeed;
  }

  void reset() {
    _smoothedSpeed = 0.0;
    _lowSpeedCounter = 0;
    _zeroSpeedCounter = 0;
    _kalmanFilter.reset();
  }
}
