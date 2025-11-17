import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../pages/test_model_page.dart';
import '../providers/menu_provider.dart';
import '../widgets/hamburger_button.dart';
import '../widgets/menu_drawer.dart';

/// Màn hình chính của ứng dụng - quản lý menu và navigation
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    // Lấy GlobalKey để điều khiển Scaffold
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          currentPage == AppPage.map ? 'Map' : 'Test Model',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        leading: HamburgerButton(
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: MenuDrawer(
        onMapTap: () {
          Navigator.pop(context);
          ref.read(currentPageProvider.notifier).state = AppPage.map;
        },
        onTestModelTap: () {
          Navigator.pop(context);
          ref.read(currentPageProvider.notifier).state = AppPage.testModel;
        },
      ),
      body: _buildPage(currentPage),
    );
  }

  /// Build page dựa theo currentPage
  Widget _buildPage(AppPage page) {
    switch (page) {
      case AppPage.map:
        return const MapScreen();
      case AppPage.testModel:
        return const TestModelPage();
    }
  }
}
