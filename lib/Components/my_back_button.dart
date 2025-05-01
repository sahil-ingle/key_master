import 'package:flutter/material.dart';

/// A clean, accessible back button styled as a ListTile.
class MyBackButton extends StatelessWidget {
  final VoidCallback onBack;

  const MyBackButton({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Go back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBack,
          splashColor: scheme.primary.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.arrow_back,
                    color: scheme.primary,
                    size: 24,
                    semanticLabel: 'Back arrow'),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
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
