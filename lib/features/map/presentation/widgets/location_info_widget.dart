import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location.dart';
import '../providers/map_controller_provider.dart';

/// Widget hiển thị tốc độ realtime như Google Maps
class SpeedDisplayWidget extends ConsumerStatefulWidget {
  const SpeedDisplayWidget({super.key});

  @override
  ConsumerState<SpeedDisplayWidget> createState() => _SpeedDisplayWidgetState();
}

class _SpeedDisplayWidgetState extends ConsumerState<SpeedDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _displayedSpeed = 0.0;
  Location? _previousLocation;

  @override
  void initState() {
    super.initState();
    _displayedSpeed = 0.0;
    _previousLocation = null;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Cập nhật tốc độ hiển thị
  void _updateDisplayedSpeed(double newSpeed, Location? location) {
    if ((newSpeed - _displayedSpeed).abs() > 0.5 || _displayedSpeed == 0.0) {
      if (mounted) {
        setState(() {
          _displayedSpeed = newSpeed;
          if (location != null) {
            _previousLocation = location;
          }
        });
      }
    }
  }

  /// Kiểm tra xem location có hợp lệ không
  bool _isLocationValid(Location location) {
    final now = DateTime.now();
    final timeDiff = now.difference(location.timestamp).inSeconds;

    // Nếu location quá cũ (> 3 giây), không hợp lệ
    if (timeDiff > 3) {
      return false;
    }

    // Nếu accuracy quá kém (> 50m), không hợp lệ
    if (location.accuracy != null && location.accuracy! > 50) {
      return false;
    }

    return true;
  }

  /// Lấy tốc độ hợp lệ từ location
  double _getValidSpeed(Location location) {
    // Nếu location không hợp lệ, trả về 0
    if (!_isLocationValid(location)) {
      return 0.0;
    }

    // Nếu không có speed hoặc speed <= 0, trả về 0
    if (location.speed == null || location.speed! <= 0) {
      return 0.0;
    }

    // Nếu có previous location, kiểm tra xem có thay đổi vị trí đáng kể không
    if (_previousLocation != null) {
      final distance = location.distanceTo(_previousLocation!);
      final timeDiff =
          location.timestamp.difference(_previousLocation!.timestamp).inSeconds;

      // Nếu không di chuyển đáng kể (< 5m trong 2 giây), trả về 0
      if (timeDiff > 0 && distance < 5 && timeDiff <= 2) {
        return 0.0;
      }
    }

    return location.speedKmh;
  }

  Color _getSpeedColor(double speedKmh) {
    if (speedKmh < 5) return Colors.grey;
    if (speedKmh < 40) return Colors.green;
    if (speedKmh < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final currentLocation = mapState.currentLocation;

    // Lắng nghe thay đổi location và cập nhật tốc độ real-time
    ref.listen<MapState>(mapControllerProvider, (previous, next) {
      final newLocation = next.currentLocation;

      if (newLocation == null) {
        // Reset về 0 khi không có location
        if (_displayedSpeed != 0.0) {
          _updateDisplayedSpeed(0.0, null);
        }
      } else {
        // Lấy tốc độ hợp lệ (đã filter)
        final validSpeedKmh = _getValidSpeed(newLocation);
        _updateDisplayedSpeed(validSpeedKmh, newLocation);
      }
    });

    if (currentLocation == null) {
      // Hiển thị 0 nếu đã có displayedSpeed, hoặc ẩn nếu chưa có
      if (_displayedSpeed == 0.0) {
        return const SizedBox.shrink();
      }
    }

    // Lấy tốc độ hợp lệ (đã filter) để hiển thị
    final validSpeedKmh =
        currentLocation != null ? _getValidSpeed(currentLocation) : 0.0;
    final isMoving = validSpeedKmh >= 1.0;
    final speedColor = _getSpeedColor(validSpeedKmh);

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: speedColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMoving ? Icons.directions_car : Icons.location_on,
              color: speedColor,
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
                    _displayedSpeed.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: speedColor,
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isMoving ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isMoving ? 'Đang di chuyển' : 'Đang dừng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (currentLocation != null &&
                      currentLocation.accuracy != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '±${currentLocation.accuracy!.toStringAsFixed(0)}m',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
