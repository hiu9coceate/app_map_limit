/// Model đại diện cho một vị trí trên bản đồ
class Location {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed; // Tốc độ di chuyển (m/s)

  Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
  });

  /// Lấy tốc độ theo km/h
  double get speedKmh => (speed ?? 0) * 3.6;

  @override
  String toString() =>
      'Location(lat: $latitude, lng: $longitude, speed: ${speedKmh.toStringAsFixed(1)} km/h)';

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
