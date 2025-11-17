import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/menu_constants.dart';
import '../providers/menu_provider.dart';

/// Widget menu item riêng lẻ
class MenuItemWidget extends ConsumerWidget {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItemWidget({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MenuConstants.menuItemHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            // Đóng menu sau khi bấm
            ref.read(isMenuOpenProvider.notifier).state = false;
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.deepPurple,
                  size: 24,
                ),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
