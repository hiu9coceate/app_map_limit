import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/map_page.dart';

/// Screen wrapper cho MapPage (sử dụng ProviderScope nếu cần)
class MapScreen extends ConsumerWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MapPage();
  }
}
