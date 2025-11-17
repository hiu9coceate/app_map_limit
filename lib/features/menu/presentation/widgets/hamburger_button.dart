import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget nút hamburger menu (3 gạch)
class HamburgerButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const HamburgerButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
        size: 28,
      ),
      onPressed: onPressed,
    );
  }
}
