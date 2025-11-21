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
  OrtSession? _classifierSession;
  List<String> _labels = [];

  static const int inputSize = 640;
  static const int classifierInputSize = 224; // MobileNetV2 input size
  static const double confidenceThreshold = 0.5;
  static const double iouThreshold = 0.45;

  bool get isInitialized => _session != null;
  bool get hasLabels => _labels.isNotEmpty;

  /// Khởi tạo ONNX model
  Future<void> initialize() async {
    try {
      OrtEnv.instance.init();

      final modelExists = await _checkAssetExists('assets/models/yolov8n.onnx');
      if (!modelExists) {
        throw Exception(
            'Không tìm thấy file model trong assets/models/yolov8n.onnx');
      }

      final modelPath = await _copyAssetToFile('assets/models/yolov8n.onnx');

      final sessionOptions = OrtSessionOptions()
        ..setInterOpNumThreads(1)
        ..setIntraOpNumThreads(1)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

      _session = OrtSession.fromFile(File(modelPath), sessionOptions);

      _labels = await _loadLabels();

      // Khởi tạo MobileNetV2 classifier
      await _initializeClassifier();

      print('Model khởi tạo thành công');
      print('Số lượng nhãn: ${_labels.length}');
    } catch (e) {
      print('Lỗi khởi tạo model: $e');
      rethrow;
    }
  }

  /// Khởi tạo MobileNetV2 classifier
  Future<void> _initializeClassifier() async {
    try {
      print('🔍 Đang kiểm tra classifier model...');

      final classifierExists = await _checkAssetExists(
          'assets/models/mobilenetv2_speedlimit_v9.onnx');
      if (!classifierExists) {
        print('⚠️ Không tìm thấy classifier model');
        return;
      }

      print('✅ Tìm thấy classifier model, đang load...');

      final classifierPath = await _copyAssetToFile(
          'assets/models/mobilenetv2_speedlimit_v9.onnx');
      print('📁 Classifier path: $classifierPath');

      final sessionOptions = OrtSessionOptions()
        ..setInterOpNumThreads(1)
        ..setIntraOpNumThreads(1)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

      _classifierSession =
          OrtSession.fromFile(File(classifierPath), sessionOptions);

      print('✅ MobileNetV2 classifier khởi tạo thành công');
      print(
          '🎯 Classifier session: ${_classifierSession != null ? "OK" : "NULL"}');
    } catch (e) {
      print('❌ Lỗi khởi tạo classifier: $e');
      print('📋 Stack trace: ${StackTrace.current}');
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
    print('🔍 Bắt đầu detect từ file: ${imageFile.path}');

    if (_session == null) {
      throw Exception('Model chưa được khởi tạo');
    }

    if (!hasLabels) {
      throw Exception(
          'Chưa có file labels.txt. Vui lòng thêm file labels.txt vào assets/models/');
    }

    final imageBytes = await imageFile.readAsBytes();
    print('📸 Đọc được ${imageBytes.length} bytes');

    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Không thể đọc ảnh');
    }

    final originalWidth = image.width;
    final originalHeight = image.height;
    print('🖼️ Kích thước ảnh gốc: ${originalWidth}x${originalHeight}');

    // Resize về model input size (640x640)
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );
    print(
        '📏 Kích thước ảnh sau resize: ${resizedImage.width}x${resizedImage.height}');
    print('⚙️ Model input size: ${inputSize}x${inputSize}');

    // Preprocess resized image
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
      print('🤖 Đang chạy model inference...');
      outputs = _session!.run(runOptions, inputs);
      print('✅ Model chạy xong');
    } catch (e) {
      print('❌ Lỗi khi chạy model: $e');
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

    print('📊 Số detections trước NMS: ${detections.length}');

    // Apply NMS
    final filteredDetections = _applyNMS(detections);

    print('✨ Số detections sau NMS: ${filteredDetections.length}');

    // 🎯 Lấy detection có confidence cao nhất để phân loại
    if (filteredDetections.isNotEmpty) {
      // Tìm detection có conf cao nhất
      var bestDetection = filteredDetections[0];

      for (int i = 0; i < filteredDetections.length; i++) {
        if (filteredDetections[i].confidence > bestDetection.confidence) {
          bestDetection = filteredDetections[i];
        }
      }

      print('\n🎯 Detection tốt nhất được chọn:');
      print('   📊 Confidence: ${bestDetection.confidence}');
      print(
          '   📦 BBox: (${bestDetection.boundingBox.x.toInt()}, ${bestDetection.boundingBox.y.toInt()}, ${bestDetection.boundingBox.width.toInt()}, ${bestDetection.boundingBox.height.toInt()})');

      // Classify nếu có classifier
      if (_classifierSession != null) {
        print('   🤖 Bắt đầu phân loại tốc độ...');

        final speedClass = await _classifySpeedSign(
          image,
          bestDetection.boundingBox,
        );

        if (speedClass != null) {
          print('   🚦 Kết quả phân loại: $speedClass km/h');

          // Tạo detection mới với label đã phân loại
          bestDetection = DetectionResult(
            label: speedClass,
            confidence: bestDetection.confidence,
            boundingBox: bestDetection.boundingBox,
          );

          print('   ✅ Đã cập nhật label thành: $speedClass');
        } else {
          print(
              '   ⚠️ Phân loại không thành công, giữ label mặc định: ${bestDetection.label}');
        }
      } else {
        print('   ⚠️ Classifier chưa được khởi tạo, bỏ qua phân loại');
      }

      // CHỈ TRẢ VỀ 1 DETECTION TốT NHẤT
      return [bestDetection];
    }

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
      print('🔎 Output type: ${outputTensor.runtimeType}');

      if (outputTensor is! List || outputTensor.isEmpty) {
        return [];
      }

      final batch = outputTensor[0];
      if (batch is! List || batch.isEmpty) {
        return [];
      }

      print('📦 Batch length: ${batch.length}');

      // Expecting format: [5, N] where N is number of detections
      // features[0] = x_center, features[1] = y_center,
      // features[2] = width, features[3] = height, features[4] = confidence

      if (batch.length < 5) {
        print('❌ Invalid output format - expected 5 rows');
        return [];
      }

      final xCenters = batch[0] as List;
      final yCenters = batch[1] as List;
      final widths = batch[2] as List;
      final heights = batch[3] as List;
      final confidences = batch[4] as List;

      final numBoxes = xCenters.length;
      print('📊 Số boxes: $numBoxes');

      // ✅ DEBUG: IN RA 10 GIÁ TRỊ CONFIDENCE ĐẦU TIÊN
      print('🔍 Sample confidences (first 10):');
      for (int i = 0; i < 10 && i < confidences.length; i++) {
        print('   conf[$i] = ${confidences[i]}');
      }

      // ✅ DEBUG: TÌM MAX CONFIDENCE
      double maxConf = 0.0;
      int maxConfIndex = -1;
      for (int i = 0; i < confidences.length; i++) {
        final conf = (confidences[i] as num).toDouble();
        if (conf > maxConf) {
          maxConf = conf;
          maxConfIndex = i;
        }
      }
      print('📊 Max confidence found: $maxConf at index $maxConfIndex');
      print('📊 Confidence threshold: $confidenceThreshold');

      // 🎯 Calculate scale factors (originalSize / modelInputSize)
      final scaleX = imageWidth / inputSize;
      final scaleY = imageHeight / inputSize;
      print('📐 Scale factors: scaleX=$scaleX, scaleY=$scaleY');
      print('📐 Model input size: ${inputSize}x${inputSize}');

      for (int i = 0; i < numBoxes; i++) {
        final xCenter = (xCenters[i] as num).toDouble();
        final yCenter = (yCenters[i] as num).toDouble();
        final width = (widths[i] as num).toDouble();
        final height = (heights[i] as num).toDouble();
        final conf = (confidences[i] as num).toDouble();

        // 🔍 BƯỚC 1: LOG DEBUG CHO HIGH CONFIDENCE DETECTIONS
        if (conf > 0.5) {
          print('\n🎯 HIGH CONF DETECTION [$i]:');
          print('   📊 Confidence: $conf');
          print(
              '   📐 Model output coords: xC=$xCenter, yC=$yCenter, w=$width, h=$height');
          print('   📏 Original image size: ${imageWidth}x${imageHeight}');
          print('   ⚙️ Model input was: ${inputSize}x${inputSize}');
          print('   📊 Scale factors: scaleX=$scaleX, scaleY=$scaleY');
        }

        // Filter by confidence threshold
        if (conf < confidenceThreshold) {
          if (conf > 0.5) {
            print('   ❌ SKIP: conf ($conf) < threshold ($confidenceThreshold)');
          }
          continue;
        }

        // 🎯 AUTO-DETECT: Normalized [0,1] vs Pixel units
        final bool isNormalized =
            (xCenter <= 1.0 && yCenter <= 1.0 && width <= 1.0 && height <= 1.0);

        double x1, y1, x2, y2;

        if (isNormalized) {
          // Case 1: Normalized coordinates [0, 1]
          // Denormalize by multiplying with original image dimensions
          x1 = (xCenter - width / 2) * imageWidth;
          y1 = (yCenter - height / 2) * imageHeight;
          x2 = (xCenter + width / 2) * imageWidth;
          y2 = (yCenter + height / 2) * imageHeight;

          if (conf > 0.5) {
            print('   🔄 Using NORMALIZED denormalization (coords in [0,1])');
            print('   📍 Denormalized bbox: x1=$x1, y1=$y1, x2=$x2, y2=$y2');
          }
        } else {
          // Case 2: Pixel units relative to model input size (640x640)
          // Scale from model space to original image space
          x1 = (xCenter - width / 2) * scaleX;
          y1 = (yCenter - height / 2) * scaleY;
          x2 = (xCenter + width / 2) * scaleX;
          y2 = (yCenter + height / 2) * scaleY;

          if (conf > 0.5) {
            print('   🔄 Using SCALE denormalization (coords in pixel units)');
            print(
                '   📍 Before scale: x1=${xCenter - width / 2}, y1=${yCenter - height / 2}');
            print('   📍 After scale: x1=$x1, y1=$y1, x2=$x2, y2=$y2');
          }
        }

        // 🔍 BƯỚC 2: KIỂM TRA TỪNG ĐIỀU KIỆN LOẠI BỎ
        if (conf > 0.5) {
          if (x1 < 0) print('   ⚠️ WARNING: x1 ($x1) < 0');
          if (y1 < 0) print('   ⚠️ WARNING: y1 ($y1) < 0');
          if (x2 > imageWidth)
            print('   ⚠️ WARNING: x2 ($x2) > imageWidth ($imageWidth)');
          if (y2 > imageHeight)
            print('   ⚠️ WARNING: y2 ($y2) > imageHeight ($imageHeight)');
        }

        // Clamp to image bounds
        final clampedX1 = x1.clamp(0.0, imageWidth.toDouble());
        final clampedY1 = y1.clamp(0.0, imageHeight.toDouble());
        final clampedX2 = x2.clamp(0.0, imageWidth.toDouble());
        final clampedY2 = y2.clamp(0.0, imageHeight.toDouble());

        // Calculate final width and height
        final finalWidth = clampedX2 - clampedX1;
        final finalHeight = clampedY2 - clampedY1;

        // 🔍 BƯỚC 2: KIỂM TRA BBOX SIZE
        if (conf > 0.5) {
          print(
              '   📦 Final bbox after clamp: x=$clampedX1, y=$clampedY1, w=$finalWidth, h=$finalHeight');
          if (finalWidth < 10)
            print('   ⚠️ WARNING: finalWidth ($finalWidth) < 10');
          if (finalHeight < 10)
            print('   ⚠️ WARNING: finalHeight ($finalHeight) < 10');
        }

        if (finalWidth <= 0 || finalHeight <= 0) {
          if (conf > 0.5) {
            print('   ❌ SKIP: finalWidth or finalHeight <= 0');
          }
          continue;
        }

        // Use class ID 0 for now (all speed signs)
        final classId = 0;

        if (classId >= 0 && classId < _labels.length) {
          detections.add(
            DetectionResult(
              label: _labels[classId],
              confidence: conf,
              boundingBox: BoundingBox(
                x: clampedX1,
                y: clampedY1,
                width: finalWidth,
                height: finalHeight,
              ),
            ),
          );

          if (conf > 0.5) {
            print('   ✅ ADDED to detections list!');
          }

          if (i < 5) {
            print(
                '🎯 Detection $i: conf=$conf, box=(${clampedX1.toInt()},${clampedY1.toInt()},${finalWidth.toInt()},${finalHeight.toInt()})');
          }
        } else {
          if (conf > 0.5) {
            print(
                '   ❌ SKIP: classId ($classId) out of range (labels: ${_labels.length})');
          }
        }
      }
    } catch (e) {
      print('❌ Lỗi parse output: $e');
    }

    return detections;
  }

  /// Apply Non-Maximum Suppression
  List<DetectionResult> _applyNMS(List<DetectionResult> detections) {
    if (detections.isEmpty) return [];

    // Sort descending by confidence (best first)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final selected = <DetectionResult>[];
    final remaining = List<DetectionResult>.from(detections);

    while (remaining.isNotEmpty) {
      // Pick the best (highest confidence)
      final best = remaining.removeAt(0);
      selected.add(best);

      // Remove all boxes with high IoU with the best box
      remaining.removeWhere((box) {
        final iou = best.boundingBox.iou(box.boundingBox);
        return iou > iouThreshold;
      });
    }

    return selected;
  }

  /// Phân loại tốc độ từ vùng detection
  Future<String?> _classifySpeedSign(
    img.Image originalImage,
    BoundingBox bbox,
  ) async {
    if (_classifierSession == null) {
      print('⚠️ Classifier chưa được khởi tạo');
      return null;
    }

    try {
      // 1. Crop vùng detection
      final x = bbox.x.toInt().clamp(0, originalImage.width - 1);
      final y = bbox.y.toInt().clamp(0, originalImage.height - 1);
      final w = bbox.width.toInt().clamp(1, originalImage.width - x);
      final h = bbox.height.toInt().clamp(1, originalImage.height - y);

      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      print('   ✂️ Cropped: ${croppedImage.width}x${croppedImage.height}');

      // 2. Resize về 224x224 (MobileNetV2 input)
      final resizedImage = img.copyResize(
        croppedImage,
        width: classifierInputSize,
        height: classifierInputSize,
        interpolation: img.Interpolation.linear,
      );

      // 3. Convert sang grayscale
      final grayscaleImage = img.grayscale(resizedImage);

      print(
          '   🎨 Converted to grayscale: ${grayscaleImage.width}x${grayscaleImage.height}');

      // 4. Preprocess cho MobileNetV2 (Grayscale duplicate thành 3 channels)
      final inputData = _preprocessClassifierImage(grayscaleImage);

      // 5. Create input tensor [1, 3, 224, 224] (3 channels với giá trị giống nhau)
      final inputOrt = OrtValueTensor.createTensorWithDataList(
        inputData,
        [1, 3, classifierInputSize, classifierInputSize],
      );

      // 6. Run inference
      final inputs = {'input': inputOrt};
      final runOptions = OrtRunOptions();

      print('   🤖 Đang chạy MobileNetV2...');
      final outputs = _classifierSession!.run(runOptions, inputs);

      // Cleanup
      inputOrt.release();
      runOptions.release();

      if (outputs.isEmpty) {
        outputs.forEach((element) => element?.release());
        return null;
      }

      final outputTensor = outputs[0]?.value;
      outputs.forEach((element) => element?.release());

      if (outputTensor == null) return null;

      // 7. Parse output
      final speedClass = _parseClassifierOutput(outputTensor);

      return speedClass;
    } catch (e) {
      print('❌ Lỗi classification: $e');
      return null;
    }
  }

  /// Preprocess image cho classifier (Grayscale duplicate to 3 channels, CHW, normalize)
  Float32List _preprocessClassifierImage(img.Image image) {
    final imageData =
        Float32List(1 * 3 * classifierInputSize * classifierInputSize);

    int pixelIndex = 0;
    // Grayscale duplicate thành 3 channels (R=G=B) để model nhận 3 channels
    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < classifierInputSize; y++) {
        for (int x = 0; x < classifierInputSize; x++) {
          final pixel = image.getPixel(x, y);
          // Grayscale: r == g == b, duplicate cùng giá trị cho cả 3 channels
          final value = pixel.r / 255.0;
          imageData[pixelIndex++] = value;
        }
      }
    }

    return imageData;
  }

  /// Parse classifier output để lấy speed class
  String? _parseClassifierOutput(dynamic outputTensor) {
    try {
      // Output shape: [1, 11] - 11 classes
      // ['100', '110', '120', '20', '30', '40', '50', '60', '70', '80', '90']

      List<double> scores;

      if (outputTensor is List) {
        if (outputTensor.isEmpty) return null;

        // Flatten if nested
        dynamic flatList = outputTensor;
        while (flatList is List && flatList.isNotEmpty && flatList[0] is List) {
          flatList = flatList[0];
        }

        scores = (flatList as List).map((e) => (e as num).toDouble()).toList();
      } else {
        return null;
      }

      if (scores.isEmpty || scores.length != _labels.length) {
        print(
            '❌ Invalid output: ${scores.length} scores, expected ${_labels.length}');
        return null;
      }

      // Tìm class có score cao nhất
      double maxScore = scores[0];
      int maxIndex = 0;

      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      print('   📊 Classification scores: ${scores.take(5).toList()}...');
      print('   🏆 Best class: ${_labels[maxIndex]} (score: $maxScore)');

      return _labels[maxIndex];
    } catch (e) {
      print('❌ Lỗi parse classifier output: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _session?.release();
    _classifierSession?.release();
    _session = null;
    _classifierSession = null;
    OrtEnv.instance.release();
  }
}
