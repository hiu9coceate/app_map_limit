import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/detection_result.dart';

/// Service để phát hiện biển báo giao thông sử dụng ONNX Runtime
class OnnxDetectorService {
  OrtSession? _session;
  List<String> _labels = [];

  static const int inputSize = 640;
  static const double confidenceThreshold = 0.25;
  static const double iouThreshold = 0.45;

  bool get isInitialized => _session != null;
  bool get hasLabels => _labels.isNotEmpty;

  /// Khởi tạo ONNX model
  Future<void> initialize() async {
    try {
      OrtEnv.instance.init();

      final modelExists =
          await _checkAssetExists('assets/models/traffic_sign.onnx');
      if (!modelExists) {
        throw Exception(
            'Không tìm thấy file model trong assets/models/traffic_sign.onnx');
      }

      final modelPath =
          await _copyAssetToFile('assets/models/traffic_sign.onnx');

      final sessionOptions = OrtSessionOptions()
        ..setInterOpNumThreads(1)
        ..setIntraOpNumThreads(1)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

      _session = OrtSession.fromFile(File(modelPath), sessionOptions);

      _labels = await _loadLabels();

      print('Model khởi tạo thành công');
      print('Số lượng nhãn: ${_labels.length}');
    } catch (e) {
      print('Lỗi khởi tạo model: $e');
      rethrow;
    }
  }

  /// Kiểm tra asset có tồn tại không
  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Copy asset file to temporary directory
  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;

    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(assetPath);
    final filePath = path.join(tempDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return filePath;
  }

  /// Load labels from assets
  Future<List<String>> _loadLabels() async {
    try {
      final labelsData =
          await rootBundle.loadString('assets/models/labels.txt');
      final labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      if (labels.isEmpty) {
        print('Cảnh báo: File labels.txt trống');
      }

      return labels;
    } catch (e) {
      print('Cảnh báo: Không thể load file labels.txt - $e');
      return [];
    }
  }

  /// Phát hiện đối tượng trong ảnh
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (_session == null) {
      throw Exception('Model chưa được khởi tạo');
    }

    if (!hasLabels) {
      throw Exception(
          'Chưa có file labels.txt. Vui lòng thêm file labels.txt vào assets/models/');
    }

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Không thể đọc ảnh');
    }

    final originalWidth = image.width;
    final originalHeight = image.height;

    // Resize image to input size
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // Preprocess image
    final inputData = _preprocessImage(resizedImage);

    // Create input tensor
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, inputSize, inputSize],
    );

    // Run inference
    final inputs = {'images': inputOrt};
    final runOptions = OrtRunOptions();

    List<OrtValue?>? outputs;
    try {
      outputs = _session!.run(runOptions, inputs);
    } catch (e) {
      inputOrt.release();
      runOptions.release();
      throw Exception('Lỗi khi chạy model: $e');
    }

    if (outputs.isEmpty) {
      inputOrt.release();
      runOptions.release();
      return [];
    }

    final outputTensor = outputs[0]?.value;

    // Release resources
    inputOrt.release();
    runOptions.release();
    outputs.forEach((element) => element?.release());

    if (outputTensor == null) {
      return [];
    }

    // Parse detections
    final detections = _parseYOLOv8Output(
      outputTensor,
      originalWidth,
      originalHeight,
    );

    // Apply NMS
    final filteredDetections = _applyNMS(detections);

    return filteredDetections;
  }

  /// Preprocess image: normalize to [0, 1] and convert to CHW format
  Float32List _preprocessImage(img.Image image) {
    final imageData = Float32List(1 * 3 * inputSize * inputSize);

    int pixelIndex = 0;
    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = image.getPixel(x, y);
          double value;

          if (c == 0) {
            value = pixel.r / 255.0;
          } else if (c == 1) {
            value = pixel.g / 255.0;
          } else {
            value = pixel.b / 255.0;
          }

          imageData[pixelIndex++] = value;
        }
      }
    }

    return imageData;
  }

  /// Parse model outputs to detection results
  List<DetectionResult> _parseYOLOv8Output(
    dynamic outputTensor,
    int imageWidth,
    int imageHeight,
  ) {
    final detections = <DetectionResult>[];

    try {
      if (outputTensor is List) {
        final output = outputTensor[0];

        if (output is List) {
          for (int i = 0; i < output.length; i++) {
            final detection = output[i];

            if (detection is List && detection.length >= 6) {
              final centerX = detection[0] as double;
              final centerY = detection[1] as double;
              final width = detection[2] as double;
              final height = detection[3] as double;
              final confidence = detection[4] as double;
              final classId = (detection[5] as double).toInt();

              if (confidence > confidenceThreshold &&
                  classId >= 0 &&
                  classId < _labels.length) {
                final scaleX = imageWidth / inputSize;
                final scaleY = imageHeight / inputSize;

                final x = (centerX - width / 2) * scaleX;
                final y = (centerY - height / 2) * scaleY;
                final w = width * scaleX;
                final h = height * scaleY;

                detections.add(
                  DetectionResult(
                    label: _labels[classId],
                    confidence: confidence,
                    boundingBox: BoundingBox(
                      x: x.clamp(0, imageWidth.toDouble()),
                      y: y.clamp(0, imageHeight.toDouble()),
                      width: w.clamp(0, imageWidth.toDouble()),
                      height: h.clamp(0, imageHeight.toDouble()),
                    ),
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      print('Lỗi parse output: $e');
    }

    return detections;
  }

  /// Apply Non-Maximum Suppression
  List<DetectionResult> _applyNMS(List<DetectionResult> detections) {
    if (detections.isEmpty) return [];

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final selected = <DetectionResult>[];
    final suppressed = <int>{};

    for (int i = 0; i < detections.length; i++) {
      if (suppressed.contains(i)) continue;

      selected.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed.contains(j)) continue;

        final iou = detections[i].boundingBox.iou(detections[j].boundingBox);

        if (iou > iouThreshold) {
          suppressed.add(j);
        }
      }
    }

    return selected;
  }

  /// Dispose resources
  void dispose() {
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
  }
}
