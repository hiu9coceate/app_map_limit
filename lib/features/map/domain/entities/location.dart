import 'dart:math';

/// Model đại diện cho một vị trí trên bản đồ
class Location {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed; // Tốc độ di chuyển (m/s)
  final DateTime timestamp; // Thời gian lấy vị trí

  Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Lấy tốc độ theo km/h
  double get speedKmh => (speed ?? 0) * 3.6;

  /// Tính khoảng cách đến vị trí khác (đơn vị: mét)
  double distanceTo(Location other) {
    const double earthRadius = 6371000; // Bán kính Trái Đất (m)

    final lat1 = latitude * (pi / 180);
    final lat2 = other.latitude * (pi / 180);
    final dLat = (other.latitude - latitude) * (pi / 180);
    final dLon = (other.longitude - longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    DateTime? timestamp,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'Location(lat: $latitude, lng: $longitude, speed: ${speedKmh.toStringAsFixed(1)} km/h, accuracy: ${accuracy?.toStringAsFixed(1)}m)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          accuracy == other.accuracy &&
          altitude == other.altitude &&
          speed == other.speed;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      accuracy.hashCode ^
      altitude.hashCode ^
      speed.hashCode;
}
