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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
            : LatLng(10.8231, 106.6797); // Mặc định: TP.HCM

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialLatLng,
        initialZoom: mapState.zoom,
        onTap: (tapPosition, point) {
          // Xử lý khi tap trên bản đồ
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

/// Widget đánh dấu vị trí hiện tại
class CurrentLocationMarker extends StatelessWidget {
  const CurrentLocationMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const SizedBox(width: 16, height: 16),
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
