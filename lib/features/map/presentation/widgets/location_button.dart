import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/location_provider.dart';
import '../providers/map_controller_provider.dart';

/// Button để lấy vị trí hiện tại của người dùng
class CurrentLocationButton extends ConsumerWidget {
  final VoidCallback? onLocationFound;
  final VoidCallback? onLocationError;

  const CurrentLocationButton({
    Key? key,
    this.onLocationFound,
    this.onLocationError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _handleGetLocation(context, ref),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.my_location),
    );
  }

  Future<void> _handleGetLocation(BuildContext context, WidgetRef ref) async {
    try {
      // Cập nhật trạng thái loading
      ref.read(mapControllerProvider.notifier).setLoading(true);

      // Lấy vị trí hiện tại
      final currentLocation = await ref.read(currentLocationProvider.future);

      // Cập nhật state bản đồ
      ref
          .read(mapControllerProvider.notifier)
          .setCurrentLocation(currentLocation);

      // Gọi callback nếu có
      onLocationFound?.call();

      // Xóa thông báo lỗi nếu có
      ref.read(mapControllerProvider.notifier).setError(null);
    } catch (e) {
      // Xử lý lỗi
      final errorMessage = _getErrorMessage(e);
      ref.read(mapControllerProvider.notifier).setError(errorMessage);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $errorMessage')),
        );
      }

      onLocationError?.call();
    } finally {
      ref.read(mapControllerProvider.notifier).setLoading(false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Dịch vụ định vị bị tắt')) {
      return 'Vui lòng bật dịch vụ định vị';
    } else if (error.toString().contains('Không có quyền')) {
      return 'Vui lòng cấp quyền truy cập vị trí';
    }
    return error.toString();
  }
}
