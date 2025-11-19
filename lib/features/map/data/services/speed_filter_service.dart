import 'dart:math';

class SpeedFilterService {
  static const double _maxAcceleration =
      5.0; // m/s² - tăng để phản ứng nhanh hơn
  static const int _smoothingWindow = 3; // Giảm xuống 3 để nhanh hơn
  static const double _kalmanQ = 0.05; // Giảm để tin GPS hơn
  static const double _kalmanR = 0.15; // Giảm để phản ứng nhanh hơn
  static const double _standstillThreshold = 0.5; // m/s (~1.8 km/h)

  final List<double> _speedHistory = [];
  double _kalmanEstimate = 0.0;
  double _kalmanError = 1.0;
  double _lastValidSpeed = 0.0;
  DateTime? _lastUpdateTime;
  int _standstillCount = 0;

  double filterSpeed(double rawSpeed, double? accuracy, DateTime timestamp) {
    // Nếu accuracy kém quá (> 30m), giữ tốc độ cũ
    if (accuracy != null && accuracy > 30) {
      return _lastValidSpeed;
    }

    double filteredSpeed = rawSpeed;

    // 1. Kiểm tra đứng yên
    if (filteredSpeed < _standstillThreshold) {
      _standstillCount++;
      // Chỉ set về 0 sau 2 lần liên tiếp < threshold
      if (_standstillCount >= 2) {
        filteredSpeed = 0.0;
        _resetFilter();
      }
    } else {
      _standstillCount = 0;
    }

    // 2. Áp dụng giới hạn tăng tốc (chỉ khi có tốc độ hợp lý)
    if (filteredSpeed > 0) {
      filteredSpeed = _applyAccelerationLimit(filteredSpeed, timestamp);
    }

    // 3. Kalman filter nhẹ - ưu tiên GPS reading
    if (filteredSpeed > 0) {
      filteredSpeed = _applyLightweightKalman(filteredSpeed);
    }

    // 4. Moving average ngắn - chỉ 3 samples
    if (filteredSpeed > 0) {
      filteredSpeed = _applyMovingAverage(filteredSpeed);
    }

    _lastValidSpeed = filteredSpeed;
    _lastUpdateTime = timestamp;

    return filteredSpeed;
  }

  double _applyAccelerationLimit(double speed, DateTime timestamp) {
    if (_lastUpdateTime == null || _lastValidSpeed == 0) {
      return speed;
    }

    final timeDiff =
        timestamp.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    if (timeDiff <= 0 || timeDiff > 2.0) {
      return speed;
    }

    final speedDiff = (speed - _lastValidSpeed).abs();
    final acceleration = speedDiff / timeDiff;

    // Chỉ giới hạn khi tăng tốc quá nhanh bất thường
    if (acceleration > _maxAcceleration) {
      final maxSpeedChange = _maxAcceleration * timeDiff;
      if (speed > _lastValidSpeed) {
        return _lastValidSpeed + maxSpeedChange;
      } else {
        return max(0, _lastValidSpeed - maxSpeedChange);
      }
    }

    return speed;
  }

  double _applyLightweightKalman(double measurement) {
    // Kalman nhẹ - ưu tiên measurement hơn
    final kalmanGain = _kalmanError / (_kalmanError + _kalmanR);

    _kalmanEstimate =
        _kalmanEstimate + kalmanGain * (measurement - _kalmanEstimate);

    _kalmanError = (1 - kalmanGain) * _kalmanError + _kalmanQ;

    // Nếu measurement thay đổi lớn, reset Kalman để phản ứng nhanh
    if ((measurement - _kalmanEstimate).abs() > 2.0) {
      _kalmanEstimate = measurement;
      _kalmanError = 1.0;
    }

    return _kalmanEstimate;
  }

  double _applyMovingAverage(double speed) {
    _speedHistory.add(speed);

    if (_speedHistory.length > _smoothingWindow) {
      _speedHistory.removeAt(0);
    }

    if (_speedHistory.isEmpty) {
      return speed;
    }

    // Weighted average - ưu tiên mẫu mới nhất
    if (_speedHistory.length == 1) {
      return _speedHistory[0];
    }

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < _speedHistory.length; i++) {
      final weight = (i + 1).toDouble(); // Mẫu mới có weight cao hơn
      weightedSum += _speedHistory[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  void _resetFilter() {
    _speedHistory.clear();
    _kalmanEstimate = 0.0;
    _kalmanError = 1.0;
  }

  void reset() {
    _speedHistory.clear();
    _kalmanEstimate = 0.0;
    _kalmanError = 1.0;
    _lastValidSpeed = 0.0;
    _lastUpdateTime = null;
    _standstillCount = 0;
  }
}
