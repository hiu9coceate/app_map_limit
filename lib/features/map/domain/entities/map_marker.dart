import 'location.dart';

/// Model đại diện cho một marker trên bản đồ
class MapMarker {
  final String id;
  final Location location;
  final String title;
  final String? description;
  final String? iconUrl;

  MapMarker({
    required this.id,
    required this.location,
    required this.title,
    this.description,
    this.iconUrl,
  });

  MapMarker copyWith({
    String? id,
    Location? location,
    String? title,
    String? description,
    String? iconUrl,
  }) {
    return MapMarker(
      id: id ?? this.id,
      location: location ?? this.location,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  @override
  String toString() => 'MapMarker(id: $id, title: $title, location: $location)';
}
