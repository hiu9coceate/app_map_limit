import 'package:flutter/material.dart';

/// Model thông tin menu item
class MenuItem {
  final String id;
  final String label;
  final IconData icon;
  final Function() onTap;

  MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
