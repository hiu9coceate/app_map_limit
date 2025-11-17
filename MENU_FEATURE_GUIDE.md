# Menu Feature - Hướng Dẫn Cấu Trúc

## 📁 Cấu Trúc Thư Mục

```
lib/features/menu/
├── core/
│   └── constants/
│       └── menu_constants.dart          # Các hằng số về animation, kích thước
├── domain/
│   └── entities/
│       └── menu_item.dart               # Model cho menu item
├── presentation/
│   ├── pages/
│   │   └── test_model_page.dart        # Trang Test Model (placeholder)
│   ├── screens/
│   │   └── main_screen.dart            # Màn hình chính - quản lý navigation
│   ├── providers/
│   │   └── menu_provider.dart          # Riverpod providers cho menu state
│   └── widgets/
│       ├── hamburger_button.dart       # Nút 3 gạch
│       ├── menu_drawer.dart            # Drawer menu chính
│       └── menu_item_widget.dart       # Widget menu item riêng lẻ
```

## 🔄 Flow Hoạt Động

### 1. **MainScreen** (màn hình chính)
- Quản lý navigation giữa các trang (Map, Test Model)
- Cung cấp AppBar với nút hamburger
- Có drawer menu

### 2. **Hamburger Button** (nút 3 gạch)
- Khi bấm: mở/đóng menu drawer
- Có animation từ 3 gạch → X

### 3. **Menu Drawer** (menu bên trái)
- Hiển thị header với icon
- Danh sách menu items (Xem Map, Test Model)
- Footer hiển thị phiên bản

### 4. **Menu Item Widget** (item menu)
- Hiển thị icon + label
- Khi bấm: gọi callback, đóng menu, cập nhật currentPage

### 5. **Providers** (quản lý state)
- `currentPageProvider`: Trang hiện tại (Map/TestModel)
- `isMenuOpenProvider`: Trạng thái menu (mở/đóng)

## 📝 Cách Thêm Menu Item Mới

Sửa file `lib/features/menu/presentation/widgets/menu_drawer.dart`:

```dart
MenuItemWidget(
  id: 'newPage',
  label: 'Tên Trang Mới',
  icon: Icons.your_icon,
  onTap: () {
    // Action khi bấm
  },
),
```

Thêm trang mới vào `_buildPage()` trong `main_screen.dart`:

```dart
case AppPage.newPage:
  return const YourNewPage();
```

Thêm enum vào `menu_provider.dart`:

```dart
enum AppPage {
  map,
  testModel,
  newPage,  // Thêm đây
}
```

## 🎨 Styling

- **Màu chính**: Colors.deepPurple
- **Màu menu**: Colors.deepPurple (header)
- **Menu width**: 280.0
- **Animation duration**: 300ms
- **Menu item height**: 60.0

## 🔗 Kết Nối Với Map Feature

- MapScreen được import từ `lib/features/map/presentation/screens/map_screen.dart`
- MapScreen bao bọc MapPage để dễ quản lý
- Khi bấm "Xem Map", navigationProvider cập nhật và hiển thị MapScreen

## ⚙️ Providers Chi Tiết

### `currentPageProvider`
```dart
final currentPageProvider = StateProvider<AppPage>((ref) => AppPage.map);
```
- Quản lý trang hiện tại
- Giá trị mặc định: AppPage.map

### `isMenuOpenProvider`
```dart
final isMenuOpenProvider = StateProvider<bool>((ref) => false);
```
- Quản lý trạng thái menu (mở/đóng)
- Được sử dụng bởi HamburgerButton và MenuItemWidget

## 🚀 Cách Sử Dụng

### Trong Widget
```dart
// Lấy trang hiện tại
final currentPage = ref.watch(currentPageProvider);

// Thay đổi trang
ref.read(currentPageProvider.notifier).state = AppPage.map;

// Thay đổi trạng thái menu
ref.read(isMenuOpenProvider.notifier).state = true;
```

## 📱 Ví Dụ: Thêm Trang Mới

1. **Tạo page mới** (`lib/features/yourfeature/presentation/pages/your_page.dart`):
```dart
class YourPage extends StatelessWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Page')),
      body: const Center(child: Text('Your Content')),
    );
  }
}
```

2. **Thêm enum** vào `menu_provider.dart`:
```dart
enum AppPage {
  map,
  testModel,
  yourNewPage,  // Thêm
}
```

3. **Thêm case** vào `main_screen.dart`:
```dart
case AppPage.yourNewPage:
  return const YourPage();
```

4. **Thêm menu item** vào `menu_drawer.dart`:
```dart
MenuItemWidget(
  id: 'yourNewPage',
  label: 'Your Page',
  icon: Icons.your_icon,
  onTap: () {
    // Navigate
  },
),
```

## 🐛 Debug Tips

- Menu không mở? Kiểm tra `isMenuOpenProvider`
- Trang không hiển thị? Kiểm tra `currentPageProvider` và switch case
- Animation không mịn? Xem `MenuConstants.animationDuration`
