import 'package:flutter/material.dart';

/// Trang test model - hiện tại chỉ là placeholder
class TestModelPage extends StatelessWidget {
  const TestModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Model'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: Colors.deepPurple.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chức năng Test Model',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sẽ được phát triển sau',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
