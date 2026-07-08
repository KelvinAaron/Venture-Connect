import 'package:flutter/material.dart';

/// Generic colored pill for showing a short status label (application
/// status, verification status, opportunity status, etc). The color
/// mapping for each domain status lives with that domain's model.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const StatusBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
