import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

class ETABadge extends StatelessWidget {
  final int minutes;
  
  const ETABadge({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;

    if (minutes <= 5) {
      bgColor = AppColors.busOnTime;
      text = "$minutes min";
    } else if (minutes <= 20) {
      bgColor = AppColors.busDelayed;
      text = "$minutes min";
    } else {
      bgColor = AppColors.busCrowded;
      text = "30+ min";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
