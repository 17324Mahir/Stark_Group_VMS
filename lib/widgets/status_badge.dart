import 'package:flutter/material.dart';
import '../models/vehicle.dart';

/// Reusable status chip/badge displaying current vehicle condition.
class StatusBadge extends StatelessWidget {
  final VehicleStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = status.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = baseColor.withValues(alpha: isDark ? 0.22 : 0.12);
    final borderColor = baseColor.withValues(alpha: isDark ? 0.45 : 0.25);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: baseColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
