/// Loại marker trên bản đồ
enum MarkerType {
  currentLocation,
  destination,
  waypoint,
  custom,
}

/// Hằng số cho tính năng bản đồ
class MapConstants {
  /// Tọa độ mặc định (TP. Hồ Chí Minh)
  static const double defaultLatitude = 10.8231;
  static const double defaultLongitude = 106.6797;

  /// Mức zoom mặc định
  static const double defaultZoom = 13.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 19.0;

  /// Khoảng cách lọc vị trí (meter)
  static const int locationUpdateDistance = 10;

  /// URL cho OpenStreetMap tiles
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Thời gian timeout cho lấy vị trí (giây)
  static const Duration locationTimeout = Duration(seconds: 30);

  /// Độ chính xác tối thiểu (meter)
  static const double minAccuracy = 100.0;
}
