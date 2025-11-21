import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../traffic_sign/presentation/providers/detection_provider.dart';
import '../../../traffic_sign/presentation/widgets/detection_result_widget.dart';
import '../../../traffic_sign/presentation/widgets/image_with_boxes_widget.dart';
import '../../../traffic_sign/presentation/widgets/upload_image_zone.dart';

class TestModelPage extends ConsumerStatefulWidget {
  const TestModelPage({super.key});

  @override
  ConsumerState<TestModelPage> createState() => _TestModelPageState();
}

class _TestModelPageState extends ConsumerState<TestModelPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(detectionStateProvider.notifier).initializeModel();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);
        ref.read(detectionStateProvider.notifier).setImage(imageFile);

        // Tự động phát hiện ngay sau khi chọn ảnh
        await ref
            .read(detectionStateProvider.notifier)
            .detectFromCurrentImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn nguồn ảnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Colors.deepPurple),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detectionState = ref.watch(detectionStateProvider);

    if (detectionState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(detectionState.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(detectionStateProvider.notifier).clearError();
                },
              ),
              duration: const Duration(seconds: 5),
            ),
          );
          ref.read(detectionStateProvider.notifier).clearError();
        }
      });
    }

    if (detectionState.isLoading && !detectionState.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi tạo model...'),
            ],
          ),
        ),
      );
    }

    if (detectionState.selectedImage == null) {
      return Scaffold(
        body: UploadImageZone(
          onTap: _showImageSourceDialog,
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: Center(
                    child: detectionState.detections.isEmpty &&
                            !detectionState.isDetecting
                        ? Image.file(
                            detectionState.selectedImage!,
                            fit: BoxFit.contain,
                          )
                        : ImageWithBoxesWidget(
                            imageFile: detectionState.selectedImage!,
                            detections: detectionState.detections,
                          ),
                  ),
                ),
                if (detectionState.isDetecting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Đang phát hiện...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      ref.read(detectionStateProvider.notifier).clearResults();
                    },
                    child: const Icon(Icons.close, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: DetectionResultWidget(
              detections: detectionState.detections,
              isDetecting: detectionState.isDetecting,
              hasImage: detectionState.selectedImage != null,
              onDetect: () => ref
                  .read(detectionStateProvider.notifier)
                  .detectFromCurrentImage(),
              onChangeImage: _showImageSourceDialog,
            ),
          ),
        ],
      ),
    );
  }
}
