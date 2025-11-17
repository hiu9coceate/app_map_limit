/// Thông báo lỗi cho tính năng bản đồ
class MapErrorMessages {
  static const String locationServiceDisabled =
      'Dịch vụ định vị bị tắt. Vui lòng bật dịch vụ định vị.';

  static const String locationPermissionDenied =
      'Không có quyền truy cập vị trí của người dùng';

  static const String locationServiceError =
      'Không thể lấy vị trí. Vui lòng thử lại.';

  static const String locationTimeout = 'Hết thời gian chờ lấy vị trí.';

  static const String invalidLocation = 'Vị trí không hợp lệ.';

  static const String markerNotFound = 'Marker không tìm thấy.';

  static const String unknownError = 'Có lỗi không xác định xảy ra.';
}
