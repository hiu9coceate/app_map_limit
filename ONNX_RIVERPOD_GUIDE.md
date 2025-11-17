# 🤖 Hướng Dẫn Chi Tiết: ONNX Runtime + Riverpod

## 📚 Mục Lục

1. [Cài Đặt Ban Đầu](#cài-đặt-ban-đầu)
2. [Cấu Trúc Project](#cấu-trúc-project)
3. [Tạo Inference Service](#tạo-inference-service)
4. [Sử Dụng Riverpod Providers](#sử-dụng-riverpod-providers)
5. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
6. [Best Practices](#best-practices)

---

## 🎯 Cài Đặt Ban Đầu

### Dependencies Cần Thiết
```yaml
dependencies:
  flutter:
    sdk: flutter
  onnxruntime: ^1.16.0
  flutter_riverpod: ^2.4.0
  riverpod: ^2.4.0
  riverpod_annotation: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

### Cài Đặt
```powershell
fvm flutter pub add onnxruntime flutter_riverpod riverpod riverpod_annotation
fvm flutter pub add -d build_runner riverpod_generator
```

---

## 📁 Cấu Trúc Project

```
lib/
├── main.dart                          # Entry point
├── config/
│   └── onnx_config.dart              # ONNX config constants
├── models/
│   ├── inference_input.dart          # Input model
│   └── inference_output.dart         # Output model
├── services/
│   └── onnx_service.dart             # ONNX inference logic
├── providers/
│   ├── model_provider.dart           # Model loading provider
│   └── inference_provider.dart       # Inference provider
└── screens/
    └── inference_screen.dart         # UI layer

assets/
└── models/
    ├── mobilenet.onnx                # Example model
    └── model_metadata.json           # Model info
```

---

## 🔧 Tạo Inference Service

### 1. Config File (`lib/config/onnx_config.dart`)

```dart
// Configuration constants for ONNX Runtime

class OnnxConfig {
  // Model paths
  static const String mobileNetModelPath = 'assets/models/mobilenet.onnx';
  
  // Input/Output configuration
  static const String inputNodeName = 'input';
  static const String outputNodeName = 'output';
  
  // Model metadata
  static const List<int> inputShape = [1, 224, 224, 3];
  static const int numClasses = 1000;
  
  // Inference settings
  static const int numThreads = 4;
  static const bool useNnapi = true;
  static const bool useQnnp = true;
}
```

### 2. Input/Output Models (`lib/models/`)

```dart
// lib/models/inference_input.dart
class InferenceInput {
  final List<List<List<List<double>>>> data;
  final String modelName;

  InferenceInput({
    required this.data,
    required this.modelName,
  });

  factory InferenceInput.fromImageData(
    List<int> imageData, {
    required String modelName,
    required int width,
    required int height,
  }) {
    // Convert raw image data to normalized float32 array
    final Float32List normalized = _normalizeImageData(imageData, width, height);
    final reshaped = _reshape(normalized, [1, height, width, 3]);
    
    return InferenceInput(
      data: reshaped,
      modelName: modelName,
    );
  }

  static List<List<List<List<double>>>> _reshape(
    Float32List data,
    List<int> shape,
  ) {
    // Reshape logic here
    // Return 4D array
    return [];
  }

  static Float32List _normalizeImageData(
    List<int> imageData,
    int width,
    int height,
  ) {
    // Normalize pixel values to [0, 1] or [-1, 1] depending on model
    final normalized = Float32List(width * height * 3);
    for (int i = 0; i < imageData.length; i++) {
      normalized[i] = imageData[i] / 255.0;
    }
    return normalized;
  }
}

// lib/models/inference_output.dart
class InferenceOutput {
  final List<List<double>> predictions;
  final Duration inferenceTime;
  final String modelName;

  InferenceOutput({
    required this.predictions,
    required this.inferenceTime,
    required this.modelName,
  });

  /// Get top-k predictions
  List<(int index, double score)> getTopPredictions(int k) {
    final first = predictions.first;
    final indexed = first
        .asMap()
        .entries
        .map((e) => (e.key, e.value))
        .toList();
    indexed.sort((a, b) => b.$2.compareTo(a.$2));
    return indexed.take(k).toList();
  }

  double get confidence => predictions.first.reduce((a, b) => a > b ? a : b);
}
```

### 3. ONNX Service (`lib/services/onnx_service.dart`)

```dart
import 'package:onnxruntime/onnxruntime.dart';
import 'package:app_map_limit/config/onnx_config.dart';
import 'package:app_map_limit/models/inference_input.dart';
import 'package:app_map_limit/models/inference_output.dart';

class OnnxService {
  late final OrtEnv _env;
  OrtSession? _session;
  bool _isInitialized = false;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize OnnxService
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create OnnxRuntime environment
      _env = OrtEnv.instance();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize OnnxService: $e');
    }
  }

  /// Load model from assets
  Future<void> loadModel(String modelPath) async {
    try {
      _session = OrtSession.fromAsset(modelPath);
      print('✅ Model loaded: $modelPath');
    } catch (e) {
      throw Exception('Failed to load model from $modelPath: $e');
    }
  }

  /// Load model from file (for custom paths)
  Future<void> loadModelFromFile(String filePath) async {
    try {
      _session = OrtSession.fromFile(filePath);
      print('✅ Model loaded from file: $filePath');
    } catch (e) {
      throw Exception('Failed to load model from $filePath: $e');
    }
  }

  // ============================================================================
  // Inference
  // ============================================================================

  /// Run inference
  Future<InferenceOutput> runInference(InferenceInput input) async {
    if (_session == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      final startTime = DateTime.now();

      // Prepare input tensors
      final inputMap = <String, OrtValueTensor>{
        OnnxConfig.inputNodeName: OrtValueTensor.createTensorAsType(
          input.data,
          DartType.float32,
        ),
      };

      // Run inference
      final output = _session!.run(null, inputMap);

      final endTime = DateTime.now();
      final inferenceTime = endTime.difference(startTime);

      // Extract output
      final predictions = output as List<List<double>>;

      return InferenceOutput(
        predictions: predictions,
        inferenceTime: inferenceTime,
        modelName: input.modelName,
      );
    } catch (e) {
      throw Exception('Inference failed: $e');
    }
  }

  /// Batch inference
  Future<List<InferenceOutput>> runBatchInference(
    List<InferenceInput> inputs,
  ) async {
    final results = <InferenceOutput>[];
    for (final input in inputs) {
      final output = await runInference(input);
      results.add(output);
    }
    return results;
  }

  // ============================================================================
  // Utilities
  // ============================================================================

  /// Get model input shape
  List<int> getInputShape() {
    return OnnxConfig.inputShape;
  }

  /// Get model output size
  int getOutputSize() {
    return OnnxConfig.numClasses;
  }

  /// Dispose resources
  void dispose() {
    _session?.release();
    _session = null;
  }
}
```

---

## 🎛️ Sử Dụng Riverpod Providers

### 1. Model Provider (`lib/providers/model_provider.dart`)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_map_limit/services/onnx_service.dart';
import 'package:app_map_limit/config/onnx_config.dart';

part 'model_provider.g.dart';

/// Initialize OnnxService (singleton)
@riverpod
Future<OnnxService> onnxService(OnnxServiceRef ref) async {
  final service = OnnxService();
  await service.initialize();
  
  // Load default model
  await service.loadModel(OnnxConfig.mobileNetModelPath);
  
  // Cleanup on dispose
  ref.onDispose(() => service.dispose());
  
  return service;
}

/// Watch for model loading state
@riverpod
Future<void> modelLoading(ModelLoadingRef ref) async {
  await ref.watch(onnxServiceProvider.future);
}
```

### 2. Inference Provider (`lib/providers/inference_provider.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_map_limit/models/inference_input.dart';
import 'package:app_map_limit/models/inference_output.dart';
import 'package:app_map_limit/providers/model_provider.dart';

part 'inference_provider.g.dart';

/// Run inference with input
@riverpod
Future<InferenceOutput> runInference(
  RunInferenceRef ref,
  InferenceInput input,
) async {
  final service = await ref.watch(onnxServiceProvider.future);
  return service.runInference(input);
}

/// Cache recent inferences
final recentInferencesProvider =
    StateNotifierProvider<RecentInferencesNotifier, List<InferenceOutput>>(
  (ref) => RecentInferencesNotifier(),
);

class RecentInferencesNotifier extends StateNotifier<List<InferenceOutput>> {
  RecentInferencesNotifier() : super([]);

  void addInference(InferenceOutput output) {
    state = [output, ...state].take(10).toList(); // Keep last 10
  }

  void clear() {
    state = [];
  }
}
```

---

## 💡 Ví Dụ Thực Tế

### Ví Dụ 1: Inference từ Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_map_limit/providers/inference_provider.dart';
import 'package:app_map_limit/models/inference_input.dart';

class InferenceScreen extends ConsumerWidget {
  const InferenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ONNX Inference')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _runInference(context, ref),
              child: const Text('Run Inference'),
            ),
            const SizedBox(height: 20),
            ref.watch(runInferenceProvider).when(
              data: (output) => Column(
                children: [
                  Text('Inference Time: ${output.inferenceTime.inMilliseconds}ms'),
                  Text('Confidence: ${output.confidence.toStringAsFixed(3)}'),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, st) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  void _runInference(BuildContext context, WidgetRef ref) {
    // Create dummy input
    final input = InferenceInput(
      data: [
        [
          [
            [0.1, 0.2, 0.3],
            [0.4, 0.5, 0.6]
          ]
        ]
      ],
      modelName: 'mobilenet',
    );

    ref.refresh(runInferenceProvider(input));
  }
}
```

### Ví Dụ 2: Batch Processing

```dart
class BatchInferenceScreen extends ConsumerWidget {
  const BatchInferenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Inference')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final service = await ref.read(onnxServiceProvider.future);
            
            // Create multiple inputs
            final inputs = List.generate(5, (i) {
              return InferenceInput(
                data: [
                  [
                    [
                      [0.1 * i, 0.2 * i, 0.3 * i],
                      [0.4 * i, 0.5 * i, 0.6 * i]
                    ]
                  ]
                ],
                modelName: 'mobilenet',
              );
            });

            // Run batch
            final results = await service.runBatchInference(inputs);
            
            // Update UI with results
            ref.read(recentInferencesProvider.notifier).addInference(results.first);
          },
          child: const Text('Run Batch Inference'),
        ),
      ),
    );
  }
}
```

### Ví Dụ 3: Với StateNotifierProvider

```dart
@riverpod
class InferenceController extends _$InferenceController {
  @override
  Future<InferenceOutput?> build() async {
    return null;
  }

  Future<void> runInference(InferenceInput input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(onnxServiceProvider.future);
      final output = await service.runInference(input);
      
      // Save to recent
      ref.read(recentInferencesProvider.notifier).addInference(output);
      
      return output;
    });
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
```

---

## 🏆 Best Practices

### 1. **Error Handling**
```dart
@riverpod
Future<InferenceOutput> safeInference(
  SafeInferenceRef ref,
  InferenceInput input,
) async {
  try {
    final service = await ref.watch(onnxServiceProvider.future);
    return service.runInference(input);
  } catch (e) {
    print('❌ Inference error: $e');
    rethrow; // Riverpod will catch this and show error state
  }
}
```

### 2. **Caching Results**
```dart
final cachedInferenceProvider = FutureProvider.family<
  InferenceOutput,
  InferenceInput,
>((ref, input) async {
  final service = await ref.watch(onnxServiceProvider.future);
  return service.runInference(input);
  // Riverpod caches by input value automatically
});
```

### 3. **Model Selection**
```dart
final selectedModelProvider = StateProvider<String>((ref) {
  return OnnxConfig.mobileNetModelPath;
});

@riverpod
Future<OnnxService> dynamicOnnxService(DynamicOnnxServiceRef ref) async {
  final service = OnnxService();
  await service.initialize();
  
  final modelPath = ref.watch(selectedModelProvider);
  await service.loadModel(modelPath);
  
  ref.onDispose(() => service.dispose());
  return service;
}
```

### 4. **Performance Monitoring**
```dart
class InferenceStats {
  final Duration totalTime;
  final int inferenceCount;
  final double averageTime;

  InferenceStats({
    required this.totalTime,
    required this.inferenceCount,
    required this.averageTime,
  });
}

final inferenceStatsProvider = StateNotifierProvider<
  InferenceStatsNotifier,
  InferenceStats,
>((ref) => InferenceStatsNotifier());

class InferenceStatsNotifier extends StateNotifier<InferenceStats> {
  InferenceStatsNotifier()
      : super(InferenceStats(
          totalTime: Duration.zero,
          inferenceCount: 0,
          averageTime: 0,
        ));

  void recordInference(Duration time) {
    final newTotal = state.totalTime + time;
    final newCount = state.inferenceCount + 1;
    
    state = InferenceStats(
      totalTime: newTotal,
      inferenceCount: newCount,
      averageTime: newTotal.inMilliseconds / newCount,
    );
  }

  void reset() {
    state = InferenceStats(
      totalTime: Duration.zero,
      inferenceCount: 0,
      averageTime: 0,
    );
  }
}
```

### 5. **Testing**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('OnnxService Tests', () {
    test('Initialize service', () async {
      final container = ProviderContainer();
      final service = await container.read(onnxServiceProvider.future);
      
      expect(service, isNotNull);
    });

    test('Run inference', () async {
      final container = ProviderContainer();
      final service = await container.read(onnxServiceProvider.future);
      
      final input = InferenceInput(
        data: [[[[]]]],
        modelName: 'test',
      );
      
      final output = await service.runInference(input);
      expect(output.predictions, isNotEmpty);
    });
  });
}
```

---

## 📚 Tài Liệu Tham Khảo

- [ONNX Runtime Dart Docs](https://pub.dev/packages/onnxruntime)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Best Practices](https://flutter.dev/docs)

---

**🎉 Ready to build AI-powered Flutter apps!**
