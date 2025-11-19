# 🚦 Tính năng Nhận diện Biển báo Giao thông

## ✅ Đã hoàn thành

Tính năng nhận diện biển báo giao thông sử dụng ONNX Runtime đã được xây dựng hoàn chỉnh với các thành phần:

### 📁 Cấu trúc Code

```
lib/features/traffic_sign/
├── domain/entities/
│   └── detection_result.dart          # Entity kết quả phát hiện
├── data/services/
│   └── onnx_detector_service.dart     # Service ONNX Runtime
└── presentation/
    ├── providers/
    │   └── detection_provider.dart    # Riverpod state management
    └── widgets/
        ├── image_with_boxes_widget.dart      # Hiển thị ảnh + boxes
        └── detection_result_widget.dart      # Hiển thị danh sách kết quả
```

### 🎯 Tính năng

✅ **Upload ảnh** từ thư viện hoặc camera  
✅ **Phát hiện nhiều biển báo** trong 1 ảnh  
✅ **Hiển thị bounding box** với màu khác nhau  
✅ **Hiển thị độ chính xác** của từng biển báo  
✅ **Sử dụng ONNX model** trực tiếp  
✅ **Non-Maximum Suppression (NMS)** để lọc duplicate  
✅ **Interactive zoom** cho ảnh  
✅ **Clean Architecture** với Domain/Data/Presentation layers  

### 📦 Dependencies đã thêm

```yaml
dependencies:
  image_picker: ^1.0.5      # Chọn ảnh từ gallery/camera
  image: ^4.1.3             # Xử lý ảnh
  path_provider: ^2.1.1     # Truy cập file system
  path: ^1.8.3              # Xử lý đường dẫn
  onnxruntime: ^1.4.1       # ONNX Runtime (đã có)
  flutter_riverpod: ^2.6.1  # State management (đã có)
```

### 🔧 Cấu hình Model

**Input:**
- Shape: `[1, 3, 640, 640]`
- Format: RGB, normalized to [0, 1]
- Layout: NCHW (Batch, Channels, Height, Width)

**Output:**
- Shape: `[batch, num_detections, 6]`
- Format: `[x, y, width, height, confidence, class_id]`

**Thresholds:**
- Confidence threshold: `0.5`
- IoU threshold: `0.45` (for NMS)

### 📝 Labels

File `assets/models/labels.txt` chứa 15 nhãn biển báo:

1. Biển cấm
2. Biển báo nguy hiểm
3. Biển hiệu lệnh
4. Biển chỉ dẫn
5. Biển phụ
6. Tốc độ tối đa 50
7. Tốc độ tối đa 60
8. Tốc độ tối đa 80
9. Cấm rẽ trái
10. Cấm rẽ phải
11. Cấm đi ngược chiều
12. Cấm dừng và đỗ xe
13. Đường một chiều
14. Nơi giao nhau
15. Chỗ ngoặt nguy hiểm

## 🚀 Cách sử dụng

### 1. Thêm ONNX Model

**Quan trọng:** Hiện tại file `assets/models/traffic_sign.onnx` là placeholder. Bạn cần:

1. **Train model** hoặc download pre-trained ONNX model
2. **Copy file .onnx** vào `assets/models/traffic_sign.onnx`
3. Model phải có format đúng như mô tả ở trên

### 2. Chạy ứng dụng

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

### 3. Sử dụng tính năng

1. Mở app → Menu → **Test Model**
2. Bấm nút **"Chọn ảnh"**
3. Chọn từ thư viện hoặc chụp ảnh mới
4. Xem kết quả phát hiện với bounding boxes

## 🎨 UI Components

### Empty State
- Icon search lớn
- Text hướng dẫn
- Nút "Chọn ảnh" floating

### Loading State
- Progress indicator
- Text "Đang khởi tạo model..." / "Đang phát hiện..."

### Result View
- **Top half:** Ảnh với bounding boxes (có zoom)
- **Bottom half:** Danh sách kết quả phát hiện
- Mỗi detection có:
  - Số thứ tự với màu tương ứng
  - Tên biển báo
  - Độ chính xác (%)
  - Màu indicator (xanh/cam/đỏ)

## 🔍 Model Training (Tùy chọn)

Nếu muốn train model riêng:

### Sử dụng YOLOv8

```python
from ultralytics import YOLO

# Train
model = YOLO('yolov8n.pt')
model.train(data='traffic_signs.yaml', epochs=100)

# Export to ONNX
model.export(format='onnx', imgsz=640)
```

### Dataset gợi ý

- [German Traffic Sign Dataset (GTSDB)](http://benchmark.ini.rub.de/)
- [LISA Traffic Sign Dataset](http://cvrr.ucsd.edu/LISA/lisa-traffic-sign-dataset.html)
- [Mapillary Traffic Sign Dataset](https://www.mapillary.com/dataset/trafficsign)

## 🐛 Troubleshooting

### Lỗi "Model not initialized"
- Đảm bảo file .onnx đã được đặt đúng vị trí
- Kiểm tra pubspec.yaml đã khai báo assets

### Lỗi "Failed to decode image"
- Kiểm tra format ảnh (JPG, PNG)
- Giảm kích thước ảnh nếu quá lớn

### Performance chậm
- Giảm `inputSize` từ 640 → 416
- Sử dụng model nhẹ hơn (nano thay vì small)
- Enable GPU acceleration (nếu có)

## 📚 Tài liệu tham khảo

- [ONNX Runtime Flutter](https://pub.dev/packages/onnxruntime)
- [YOLOv8 Documentation](https://docs.ultralytics.com/)
- [Image Picker](https://pub.dev/packages/image_picker)
- [Flutter Riverpod](https://riverpod.dev/)

## 🎯 Roadmap

- [ ] Thêm model thật (hiện tại là placeholder)
- [ ] Tích hợp realtime detection từ camera
- [ ] Lưu lịch sử phát hiện
- [ ] Export kết quả ra file
- [ ] Thêm nhiều loại biển báo
- [ ] Optimize performance với GPU
- [ ] Thêm chế độ offline mode

## 👥 Contribution

Để contribute:
1. Fork repo
2. Tạo branch mới
3. Commit changes
4. Push và tạo Pull Request

---

**Lưu ý:** File ONNX model hiện tại chỉ là placeholder. Vui lòng thêm model thật để tính năng hoạt động!
