/// Model đại diện cho kết quả phát hiện đối tượng
class DetectionResult {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() =>
      'DetectionResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Model đại diện cho hộp giới hạn (bounding box)
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get left => x;
  double get top => y;
  double get right => x + width;
  double get bottom => y + height;

  /// Tính IoU (Intersection over Union) với bounding box khác
  double iou(BoundingBox other) {
    final intersectLeft = left > other.left ? left : other.left;
    final intersectTop = top > other.top ? top : other.top;
    final intersectRight = right < other.right ? right : other.right;
    final intersectBottom = bottom < other.bottom ? bottom : other.bottom;

    if (intersectRight < intersectLeft || intersectBottom < intersectTop) {
      return 0.0;
    }

    final intersectArea =
        (intersectRight - intersectLeft) * (intersectBottom - intersectTop);
    final unionArea =
        (width * height) + (other.width * other.height) - intersectArea;

    return intersectArea / unionArea;
  }
}
