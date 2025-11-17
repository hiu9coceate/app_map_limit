import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location.dart';
import '../providers/location_provider.dart';
import '../providers/map_controller_provider.dart';
import '../widgets/location_button.dart';
import '../widgets/map_widget.dart';

/// Trang chính hiển thị bản đồ
class MapPage extends ConsumerStatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    // Lắng nghe stream vị trí thay đổi theo thời gian thực
    ref.listen(watchLocationProvider, (previous, next) {
      next.whenData((location) {
        // Cập nhật vị trí hiện tại
        ref.read(mapControllerProvider.notifier).setCurrentLocation(location);
      });
    });

    final mapState = ref.watch(mapControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        elevation: 0,
        centerTitle: true,
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

          // Hiển thị lỗi
          if (mapState.errorMessage != null)
            Positioned(
              top: 16,
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
      floatingActionButton: CurrentLocationButton(
        onLocationFound: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lấy vị trí hiện tại')),
          );
        },
        onLocationError: () {
          // Xử lý lỗi nếu cần
        },
      ),
    );
  }
}
