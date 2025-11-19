import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_controller_provider.dart';

class SpeedDisplayWidget extends ConsumerStatefulWidget {
  const SpeedDisplayWidget({super.key});

  @override
  ConsumerState<SpeedDisplayWidget> createState() => _SpeedDisplayWidgetState();
}

class _SpeedDisplayWidgetState extends ConsumerState<SpeedDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _speedAnimation;
  double _displayedSpeed = 0.0;
  double _targetSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Giảm từ 500ms xuống 200ms
    );

    _speedAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Đổi sang easeOut đơn giản hơn
      ),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _displayedSpeed = _speedAnimation.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateSpeed(double newSpeed) {
    // Chỉ animate khi thay đổi > 0.5 km/h
    if ((newSpeed - _targetSpeed).abs() > 0.5) {
      _targetSpeed = newSpeed;

      _speedAnimation = Tween<double>(
        begin: _displayedSpeed,
        end: _targetSpeed,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      );

      _animationController.forward(from: 0.0);
    } else if ((newSpeed - _displayedSpeed).abs() < 0.1) {
      // Nếu thay đổi rất nhỏ, set trực tiếp không animation
      setState(() {
        _displayedSpeed = newSpeed;
        _targetSpeed = newSpeed;
      });
    }
  }

  Color _getSpeedColor(double speedKmh) {
    if (speedKmh < 1) return Colors.grey;
    if (speedKmh < 40) return Colors.green;
    if (speedKmh < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final currentLocation = mapState.currentLocation;

    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    final speedKmh = currentLocation.speedKmh;
    _updateSpeed(speedKmh);

    final isMoving = _displayedSpeed >= 1.0;
    final speedColor = _getSpeedColor(_displayedSpeed);

    // Hiển thị 1 số thập phân khi < 10 km/h, nguyên khi >= 10 km/h
    final displaySpeed = _displayedSpeed < 10.0
        ? _displayedSpeed.toStringAsFixed(1)
        : _displayedSpeed.round().toString();

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displaySpeed,
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
                  if (currentLocation.accuracy != null) ...[
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
