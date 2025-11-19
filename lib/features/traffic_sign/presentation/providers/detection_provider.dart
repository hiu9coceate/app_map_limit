import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/onnx_detector_service.dart';
import '../../domain/entities/detection_result.dart';

/// Provider cho ONNX Detector Service
final onnxDetectorServiceProvider = Provider<OnnxDetectorService>((ref) {
  final service = OnnxDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider cho Detection State
final detectionStateProvider =
    StateNotifierProvider.autoDispose<DetectionNotifier, DetectionState>((ref) {
  return DetectionNotifier(ref.watch(onnxDetectorServiceProvider));
});

/// State class cho detection
class DetectionState {
  final File? selectedImage;
  final List<DetectionResult> detections;
  final bool isLoading;
  final bool isInitialized;
  final bool isDetecting;
  final String? errorMessage;

  DetectionState({
    this.selectedImage,
    this.detections = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.isDetecting = false,
    this.errorMessage,
  });

  DetectionState copyWith({
    File? selectedImage,
    List<DetectionResult>? detections,
    bool? isLoading,
    bool? isInitialized,
    bool? isDetecting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DetectionState(
      selectedImage: selectedImage ?? this.selectedImage,
      detections: detections ?? this.detections,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isDetecting: isDetecting ?? this.isDetecting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier cho detection
class DetectionNotifier extends StateNotifier<DetectionState> {
  final OnnxDetectorService _detectorService;

  DetectionNotifier(this._detectorService) : super(DetectionState());

  /// Khởi tạo model
  Future<void> initializeModel() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _detectorService.initialize();
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi khởi tạo model: $e',
      );
    }
  }

  /// Chọn ảnh - KHÔNG tự động detect
  void setImage(File imageFile) {
    state = state.copyWith(
      selectedImage: imageFile,
      detections: [],
      clearError: true,
    );
  }

  /// Phát hiện từ ảnh hiện tại
  Future<void> detectFromCurrentImage() async {
    if (state.selectedImage == null) {
      state = state.copyWith(errorMessage: 'Chưa chọn ảnh');
      return;
    }

    if (!state.isInitialized) {
      await initializeModel();
      if (!state.isInitialized) {
        return;
      }
    }

    state = state.copyWith(isDetecting: true, detections: [], clearError: true);

    try {
      final detections =
          await _detectorService.detectObjects(state.selectedImage!);

      state = state.copyWith(
        isDetecting: false,
        detections: detections,
      );
    } catch (e) {
      state = state.copyWith(
        isDetecting: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Xóa kết quả
  void clearResults() {
    state = DetectionState(isInitialized: state.isInitialized);
  }

  /// Reset về trạng thái ban đầu
  void reset() {
    state = DetectionState();
  }

  /// Xóa lỗi
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
