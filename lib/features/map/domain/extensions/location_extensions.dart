import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../entities/location.dart';

/// Extension methods cho Location
extension LocationExtensions on Location {
  /// Chuyển Location sang LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Tính khoảng cách tới Location khác (km)
  double distanceTo(Location other) {
    final distance = Distance();
    return distance.as(
      LengthUnit.kilometer,
      LatLng(latitude, longitude),
      LatLng(other.latitude, other.longitude),
    );
  }

  /// Kiểm tra xem vị trí có hợp lệ không
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Lấy tọa độ dưới dạng string
  String get coordinates => '$latitude, $longitude';

  /// Tạo Google Maps URL
  String get googleMapsUrl =>
      'https://www.google.com/maps/?q=$latitude,$longitude';

  /// Tạo OpenStreetMap URL
  String get openStreetMapUrl =>
      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude&zoom=15';
}

/// Extension methods cho LatLng
extension LatLngExtensions on LatLng {
  /// Chuyển LatLng sang Location
  Location toLocation() => Location(
        latitude: latitude,
        longitude: longitude,
      );
}

/// Lớp Distance hỗ trợ tính khoảng cách
class Distance {
  /// Tính khoảng cách giữa hai điểm (Haversine formula)
  double as(LengthUnit unit, LatLng startPoint, LatLng endPoint) {
    const earthRadius = 6371; // Bán kính Trái Đất (km)

    final dLat = _toRad(endPoint.latitude - startPoint.latitude);
    final dLon = _toRad(endPoint.longitude - startPoint.longitude);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRad(startPoint.latitude)) *
            cos(_toRad(endPoint.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return switch (unit) {
      LengthUnit.meter => distance * 1000,
      LengthUnit.kilometer => distance,
      LengthUnit.mile => distance * 0.621371,
    };
  }

  double _toRad(double degree) => degree * (3.14159265359 / 180);
}

/// Enum cho đơn vị đo độ dài
enum LengthUnit {
  meter,
  kilometer,
  mile,
}
