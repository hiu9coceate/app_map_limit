import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/entities/detection_result.dart';

/// Widget hiển thị ảnh với các bounding box
class ImageWithBoxesWidget extends StatefulWidget {
  final File imageFile;
  final List<DetectionResult> detections;

  const ImageWithBoxesWidget({
    super.key,
    required this.imageFile,
    required this.detections,
  });

  @override
  State<ImageWithBoxesWidget> createState() => _ImageWithBoxesWidgetState();
}

class _ImageWithBoxesWidgetState extends State<ImageWithBoxesWidget> {
  ui.Image? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageWithBoxesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);

    final bytes = await widget.imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);

    if (mounted) {
      setState(() {
        _image = image;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: CustomPaint(
        painter: BoundingBoxPainter(
          image: _image!,
          detections: widget.detections,
        ),
        child: Container(),
      ),
    );
  }
}

/// Custom painter để vẽ bounding boxes
class BoundingBoxPainter extends CustomPainter {
  final ui.Image image;
  final List<DetectionResult> detections;

  BoundingBoxPainter({
    required this.image,
    required this.detections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final imageAspectRatio = imageWidth / imageHeight;
    final canvasAspectRatio = size.width / size.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspectRatio > canvasAspectRatio) {
      scale = size.width / imageWidth;
      offsetY = (size.height - imageHeight * scale) / 2;
    } else {
      scale = size.height / imageHeight;
      offsetX = (size.width - imageWidth * scale) / 2;
    }

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Draw image
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      image: image,
      fit: BoxFit.contain,
    );

    // Draw bounding boxes
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final box = detection.boundingBox;
      final color = colors[i % colors.length];

      // Draw box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final rect = Rect.fromLTWH(
        box.x,
        box.y,
        box.width,
        box.height,
      );

      canvas.drawRect(rect, boxPaint);

      // Draw label background
      final labelBgPaint = Paint()..color = color;

      final textSpan = TextSpan(
        text:
            '${detection.label} ${(detection.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        box.x,
        box.y - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      canvas.drawRect(labelRect, labelBgPaint);
      textPainter.paint(
          canvas, Offset(box.x + 4, box.y - textPainter.height - 2));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.detections != detections;
  }
}
