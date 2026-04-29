import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

enum CrowdLevel { low, medium, high, veryHigh }

class CrowdIndicator extends StatelessWidget {
  final CrowdLevel level;

  const CrowdIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    int filledDots;
    Color dotColor;
    String label;

    switch (level) {
      case CrowdLevel.low:
        filledDots = 1;
        dotColor = AppColors.busOnTime;
        label = "Low";
        break;
      case CrowdLevel.medium:
        filledDots = 2;
        dotColor = AppColors.busDelayed;
        label = "Medium";
        break;
      case CrowdLevel.high:
        filledDots = 3;
        dotColor = AppColors.busDelayed;
        label = "High";
        break;
      case CrowdLevel.veryHigh:
        filledDots = 4;
        dotColor = AppColors.busCrowded;
        label = "Very High";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            bool isFilled = index < filledDots;
            return Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? dotColor : Theme.of(context).dividerColor,
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dotColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
