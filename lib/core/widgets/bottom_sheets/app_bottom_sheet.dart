import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    ),
  );
}
