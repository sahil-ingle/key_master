import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String username;
  final Function()? onTap;
  final Function()? onIconTap;
  final Widget? dragHandle;

  const MyCard({
    required this.username,
    required this.onTap,
    required this.onIconTap,
    this.dragHandle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.surface,
      // Material You emphasizes a dynamic color system
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  username,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: onIconTap,
                    splashRadius: 20,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                  const SizedBox(width: 8),
                  if (dragHandle != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        icon: Icon(
                          Icons.drag_handle,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: null, // Disabled by default
                        splashRadius: 20,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
