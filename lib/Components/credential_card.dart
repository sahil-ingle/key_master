import 'package:flutter/material.dart';

class CredentialCard extends StatelessWidget {
  final String username;
  final GestureTapCallback? onTap;
  final Function? onIconTap;
  const CredentialCard({
    required this.username,
    required this.onTap,
    this.onIconTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Text Column using theme styles.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "user@example.com",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Last modified: 2h ago",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Action Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    onPressed: () {
                      // If you need to use onIconTap, you can wrap this
                      // call accordingly, for example:
                      // if (onIconTap != null) onIconTap!();
                    },
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    onPressed: () {},
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    onPressed: () {},
                    splashRadius: 20,
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
