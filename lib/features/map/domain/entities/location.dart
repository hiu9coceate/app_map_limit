/// Model đại diện cho một vị trí trên bản đồ
class Location {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;

  Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
  });

  @override
  String toString() =>
      'Location(lat: $latitude, lng: $longitude, accuracy: $accuracy)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          accuracy == other.accuracy &&
          altitude == other.altitude;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      accuracy.hashCode ^
      altitude.hashCode;
}
