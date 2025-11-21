class KalmanFilterService {
  double _estimate = 0.0;
  double _errorCovariance = 1.0;
  bool _initialized = false;

  static const double _processNoise = 0.008;
  static const double _defaultMeasurementNoise = 0.15;
  static const double _highMeasurementNoise = 0.25;

  double _measurementNoise = _defaultMeasurementNoise;

  double filter(double measurement) {
    if (!_initialized) {
      _estimate = measurement;
      _initialized = true;
      return _estimate;
    }

    _errorCovariance += _processNoise;

    final kalmanGain =
        _errorCovariance / (_errorCovariance + _measurementNoise);

    _estimate = _estimate + kalmanGain * (measurement - _estimate);

    _errorCovariance = (1 - kalmanGain) * _errorCovariance;

    return _estimate;
  }

  void increaseMeasurementNoise() {
    _measurementNoise = _highMeasurementNoise;
  }

  void resetMeasurementNoise() {
    _measurementNoise = _defaultMeasurementNoise;
  }

  void reset() {
    _estimate = 0.0;
    _errorCovariance = 1.0;
    _initialized = false;
    _measurementNoise = _defaultMeasurementNoise;
  }
}
