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
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
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
                        color: Colors.grey.shade500,
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
                            color: Colors.grey.shade400,
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
      ),
    );
  }
}
