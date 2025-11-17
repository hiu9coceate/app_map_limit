import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/menu_constants.dart';
import '../widgets/menu_item_widget.dart';

/// Widget drawer menu chính
class MenuDrawer extends ConsumerWidget {
  final VoidCallback onMapTap;
  final VoidCallback onTestModelTap;

  const MenuDrawer({
    super.key,
    required this.onMapTap,
    required this.onTestModelTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: MenuConstants.menuWidth,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header của menu với dấu X
            Container(
              color: Colors.deepPurple,
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  MenuItemWidget(
                    id: 'map',
                    label: 'Xem Map',
                    icon: Icons.map,
                    onTap: onMapTap,
                  ),
                  MenuItemWidget(
                    id: 'testModel',
                    label: 'Test Model',
                    icon: Icons.psychology,
                    onTap: onTestModelTap,
                  ),
                ],
              ),
            ),
            // Footer của menu
            Container(
              color: Colors.grey.withOpacity(0.1),
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
