/// Exception cơ bản cho map
abstract class MapException implements Exception {
  final String message;
  MapException(this.message);

  @override
  String toString() => message;
}

/// Exception khi dịch vụ vị trí bị tắt
class LocationServiceDisabledException extends MapException {
  LocationServiceDisabledException(String message) : super(message);
}

/// Exception khi bị từ chối quyền truy cập vị trí
class LocationPermissionDeniedException extends MapException {
  LocationPermissionDeniedException(String message) : super(message);
}

/// Exception khi không thể lấy vị trí
class LocationRetrievalException extends MapException {
  LocationRetrievalException(String message) : super(message);
}

/// Exception khi marker không tìm thấy
class MarkerNotFoundException extends MapException {
  final String markerId;

  MarkerNotFoundException(this.markerId)
      : super('Marker với ID $markerId không tìm thấy');
}

/// Exception khi vị trí không hợp lệ
class InvalidLocationException extends MapException {
  InvalidLocationException(String message) : super(message);
}

/// Exception chung cho map feature
class MapFeatureException extends MapException {
  MapFeatureException(String message) : super(message);
}
