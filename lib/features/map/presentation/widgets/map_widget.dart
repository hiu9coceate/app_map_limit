import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location.dart';
import '../providers/map_controller_provider.dart';

/// Widget hiển thị bản đồ OpenStreetMap
class MapWidget extends ConsumerStatefulWidget {
  final Location? initialLocation;
  final VoidCallback? onMapReady;

  const MapWidget({
    Key? key,
    this.initialLocation,
    this.onMapReady,
  }) : super(key: key);

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  late MapController _mapController;
  bool _isFollowingUser = true;
  Location? _previousLocation;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLocationTracking();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _startLocationTracking() {
    ref.listen(mapControllerProvider, (previous, next) {
      if (_isFollowingUser && next.currentLocation != null) {
        final now = DateTime.now();
        if (_lastUpdateTime == null ||
            now.difference(_lastUpdateTime!).inMilliseconds > 50) {
          if (_hasLocationChanged(next.currentLocation!)) {
            _smoothAnimateToLocation(next.currentLocation!);
            _previousLocation = next.currentLocation;
            _lastUpdateTime = now;
          }
        }
      }
    });
  }

  bool _hasLocationChanged(Location newLocation) {
    if (_previousLocation == null) return true;

    final latDiff = (newLocation.latitude - _previousLocation!.latitude).abs();
    final lngDiff =
        (newLocation.longitude - _previousLocation!.longitude).abs();

    return latDiff > 0.000001 || lngDiff > 0.000001;
  }

  void _smoothAnimateToLocation(Location location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      _mapController.camera.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);

    // Xác định vị trí ban đầu cho bản đồ
    final initialLatLng = mapState.currentLocation != null
        ? LatLng(mapState.currentLocation!.latitude,
            mapState.currentLocation!.longitude)
        : widget.initialLocation != null
            ? LatLng(
                widget.initialLocation!.latitude,
                widget.initialLocation!.longitude,
              )
            : const LatLng(10.8231, 106.6797); // Mặc định: TP.HCM

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialLatLng,
            initialZoom: mapState.zoom,
            onTap: (tapPosition, point) {
              // Tắt chế độ follow khi người dùng tương tác với bản đồ
              setState(() {
                _isFollowingUser = false;
              });
            },
            onPositionChanged: (position, hasGesture) {
              // Tắt chế độ follow khi người dùng kéo bản đồ
              if (hasGesture) {
                setState(() {
                  _isFollowingUser = false;
                });
              }
            },
          ),
          children: [
            // Lớp nền: OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app_map_limit',
              maxNativeZoom: 19,
            ),

            // Lớp hiển thị markers
            MarkerLayer(
              markers: _buildMarkers(),
            ),

            // Lớp hiển thị vị trí hiện tại
            if (mapState.currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      mapState.currentLocation!.latitude,
                      mapState.currentLocation!.longitude,
                    ),
                    child: const CurrentLocationMarker(),
                  ),
                ],
              ),
          ],
        ),

        // Nút toggle chế độ follow location
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton.small(
            heroTag: 'follow_location',
            onPressed: () {
              setState(() {
                _isFollowingUser = !_isFollowingUser;
              });

              // Nếu bật follow, di chuyển đến vị trí hiện tại
              if (_isFollowingUser && mapState.currentLocation != null) {
                _smoothAnimateToLocation(mapState.currentLocation!);
              }
            },
            backgroundColor: _isFollowingUser ? Colors.blue : Colors.white,
            child: Icon(
              _isFollowingUser ? Icons.my_location : Icons.location_searching,
              color: _isFollowingUser ? Colors.white : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng danh sách markers từ state
  List<Marker> _buildMarkers() {
    final mapState = ref.watch(mapControllerProvider);

    return mapState.markers
        .map(
          (marker) => Marker(
            point: LatLng(marker.location.latitude, marker.location.longitude),
            child: MapMarkerWidget(marker: marker),
          ),
        )
        .toList();
  }

  /// Di chuyển bản đồ đến vị trí
  void animateTo(Location location, {double zoom = 13.0}) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      zoom,
    );
  }

  /// Lấy map controller để sử dụng từ ngoài
  MapController getMapController() => _mapController;
}

/// Widget đánh dấu vị trí hiện tại với hiệu ứng pulse như Google Maps
class CurrentLocationMarker extends StatefulWidget {
  const CurrentLocationMarker({super.key});

  @override
  State<CurrentLocationMarker> createState() => _CurrentLocationMarkerState();
}

class _CurrentLocationMarkerState extends State<CurrentLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Tạo animation cho hiệu ứng pulse
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Vòng tròn pulse bên ngoài
            Container(
              width: 40 * _pulseAnimation.value,
              height: 40 * _pulseAnimation.value,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3 / _pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
            // Vòng tròn chính
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Điểm trung tâm
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget cho các marker thông thường trên bản đồ
class MapMarkerWidget extends StatelessWidget {
  final dynamic marker;

  const MapMarkerWidget({
    Key? key,
    required this.marker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Xử lý khi tap vào marker
        _showMarkerInfo(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showMarkerInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marker.title ?? 'Marker'),
        content: Text(marker.description ?? 'Không có mô tả'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
