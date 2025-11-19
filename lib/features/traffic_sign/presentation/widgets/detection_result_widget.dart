import 'package:flutter/material.dart';
import '../../domain/entities/detection_result.dart';

/// Widget hiển thị kết quả phát hiện
class DetectionResultWidget extends StatelessWidget {
  final List<DetectionResult> detections;
  final bool isDetecting;
  final bool hasImage;
  final VoidCallback onDetect;
  final VoidCallback onChangeImage;

  const DetectionResultWidget({
    super.key,
    required this.detections,
    this.isDetecting = false,
    this.hasImage = false,
    required this.onDetect,
    required this.onChangeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Colors.deepPurple, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            detections.isEmpty && !isDetecting
                                ? 'Chưa phát hiện'
                                : 'Kết quả (${detections.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        if (detections.isEmpty && hasImage && !isDetecting)
                          ElevatedButton.icon(
                            onPressed: onDetect,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Phát hiện'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        if (hasImage)
                          OutlinedButton.icon(
                            onPressed: onChangeImage,
                            icon: const Icon(Icons.image, size: 18),
                            label: const Text('Đổi ảnh'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: detections.isEmpty && !isDetecting
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasImage ? Icons.touch_app : Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasImage
                              ? 'Nhấn "Phát hiện" để bắt đầu'
                              : 'Chọn ảnh để bắt đầu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: detections.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final detection = detections[index];
                      return _buildDetectionCard(detection, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(DetectionResult detection, int index) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow[700]!,
      Colors.purple,
      Colors.orange,
    ];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detection.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(detection.confidence)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(detection.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getConfidenceColor(detection.confidence),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
