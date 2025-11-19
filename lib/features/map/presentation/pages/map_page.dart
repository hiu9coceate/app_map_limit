import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location.dart';
import '../providers/location_provider.dart';
import '../providers/map_controller_provider.dart';
import '../widgets/location_info_widget.dart';
import '../widgets/map_widget.dart';

/// Trang chính hiển thị bản đồ
class MapPage extends ConsumerStatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  void initState() {
    super.initState();

    // Tự động yêu cầu quyền và bắt đầu theo dõi vị trí khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  /// Khởi tạo và bắt đầu theo dõi vị trí
  Future<void> _initializeLocation() async {
    try {
      // Yêu cầu quyền truy cập vị trí
      final hasPermission = await ref.read(locationPermissionProvider.future);

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cần cấp quyền truy cập vị trí để sử dụng tính năng này'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Lấy vị trí hiện tại lần đầu
      final currentLocation = await ref.read(currentLocationProvider.future);
      ref
          .read(mapControllerProvider.notifier)
          .setCurrentLocation(currentLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lấy vị trí: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe stream và cập nhật real-time
    ref.listen(watchLocationProvider, (previous, next) {
      next.when(
        data: (location) {
          ref.read(mapControllerProvider.notifier).setCurrentLocation(location);
          ref.read(mapControllerProvider.notifier).setError(null);
        },
        loading: () {},
        error: (error, stack) {
          ref.read(mapControllerProvider.notifier).setError(error.toString());
        },
      );
    });

    final mapState = ref.watch(mapControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        elevation: 0,
        centerTitle: true,
        actions: [
          // Debug info
          if (mapState.currentLocation != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${mapState.currentLocation!.speedKmh.toStringAsFixed(1)} km/h',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Bản đồ chính
          MapWidget(
            initialLocation: Location(
              latitude: 10.8231,
              longitude: 106.6797,
            ),
            onMapReady: () {
              // Gọi khi bản đồ sẵn sàng
            },
          ),

          // Hiển thị loading
          if (mapState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Hiển thị tốc độ realtime
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: const SpeedDisplayWidget(),
          ),

          // Hiển thị lỗi
          if (mapState.errorMessage != null)
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mapState.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(mapControllerProvider.notifier).setError(null);
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
