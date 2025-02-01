import 'package:flutter/material.dart';

class CredentialCard extends StatelessWidget {
  final String username;
  final GestureTapCallback? onTap;
  final Function? onIconTap;
  const CredentialCard(
      {required this.username, required this.onTap, this.onIconTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "user@example.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Last modified: 2h ago",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: Colors.amber.shade600,
                        size: 20,
                      ),
                      onPressed: () {},
                      splashRadius: 20,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () {},
                      splashRadius: 20,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.drag_handle,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () {},
                      splashRadius: 20,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
