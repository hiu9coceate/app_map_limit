import 'dart:collection';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class MovingAverageService {
  final Queue<Position> _recentPositions = Queue<Position>();
  static const int _maxQueueSize = 5;

  double calculateAverageSpeed(Position currentPosition) {
    _recentPositions.add(currentPosition);

    if (_recentPositions.length > _maxQueueSize) {
      _recentPositions.removeFirst();
    }

    if (_recentPositions.length < 3) {
      return currentPosition.speed >= 0 ? currentPosition.speed : 0.0;
    }

    final firstPosition = _recentPositions.first;
    final lastPosition = _recentPositions.last;

    final timeDiffSeconds = lastPosition.timestamp
        .difference(firstPosition.timestamp)
        .inMilliseconds /
        1000.0;

    if (timeDiffSeconds < 0.1) {
      return currentPosition.speed >= 0 ? currentPosition.speed : 0.0;
    }

    final distanceMeters = _calculateDistanceHaversine(
      firstPosition.latitude,
      firstPosition.longitude,
      lastPosition.latitude,
      lastPosition.longitude,
    );

    return distanceMeters / timeDiffSeconds;
  }

  double _calculateDistanceHaversine(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  void reset() {
    _recentPositions.clear();
  }
}

