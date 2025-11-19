import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/map_marker.dart';

/// State class cho quản lý trạng thái bản đồ
class MapState {
  final Location? currentLocation;
  final List<MapMarker> markers;
  final double zoom;
  final bool isLoading;
  final String? errorMessage;

  MapState({
    this.currentLocation,
    this.markers = const [],
    this.zoom = 13.0,
    this.isLoading = false,
    this.errorMessage,
  });

  MapState copyWith({
    Location? currentLocation,
    List<MapMarker>? markers,
    double? zoom,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      zoom: zoom ?? this.zoom,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier cho quản lý trạng thái bản đồ
class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  /// Cập nhật vị trí hiện tại
  void setCurrentLocation(Location? location) {
    state = state.copyWith(currentLocation: location);
  }

  /// Thêm marker vào bản đồ
  void addMarker(MapMarker marker) {
    final updatedMarkers = [...state.markers, marker];
    state = state.copyWith(markers: updatedMarkers);
  }

  /// Xóa marker từ bản đồ
  void removeMarker(String markerId) {
    final updatedMarkers =
        state.markers.where((m) => m.id != markerId).toList();
    state = state.copyWith(markers: updatedMarkers);
  }

  /// Cập nhật marker
  void updateMarker(MapMarker marker) {
    final updatedMarkers =
        state.markers.map((m) => m.id == marker.id ? marker : m).toList();
    state = state.copyWith(markers: updatedMarkers);
  }

  /// Xóa tất cả markers
  void clearMarkers() {
    state = state.copyWith(markers: []);
  }

  /// Cập nhật mức zoom
  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }

  /// Đặt trạng thái loading
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Đặt lỗi
  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

/// Provider cho MapNotifier
final mapControllerProvider =
    StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});

/// Utility function để chuyển Location sang LatLng
LatLng locationToLatLng(Location location) {
  return LatLng(location.latitude, location.longitude);
}

/// Utility function để chuyển LatLng sang Location
Location latLngToLocation(LatLng latLng) {
  return Location(latitude: latLng.latitude, longitude: latLng.longitude);
}
