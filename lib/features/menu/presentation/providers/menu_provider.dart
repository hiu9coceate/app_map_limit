import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum để quản lý các trang trong ứng dụng
enum AppPage {
  map,
  testModel,
}

/// Provider để quản lý trang hiện tại
final currentPageProvider = StateProvider<AppPage>((ref) => AppPage.map);

/// Provider để quản lý trạng thái menu (mở/đóng)
final isMenuOpenProvider = StateProvider<bool>((ref) => false);
