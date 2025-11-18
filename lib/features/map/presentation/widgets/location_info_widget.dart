import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_controller_provider.dart';

/// Widget hiển thị tốc độ realtime như Google Maps
class SpeedDisplayWidget extends ConsumerWidget {
  const SpeedDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);
    final currentLocation = mapState.currentLocation;

    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    final speedKmh = currentLocation.speedKmh;
    final isMoving = speedKmh > 1.0; // Coi như đang di chuyển nếu > 1 km/h

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon tốc độ
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMoving
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.speed,
              color: isMoving ? Colors.blue : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Hiển thị tốc độ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    speedKmh.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isMoving ? Colors.blue : Colors.grey[700],
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'km/h',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isMoving ? 'Đang di chuyển' : 'Đang dừng',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
