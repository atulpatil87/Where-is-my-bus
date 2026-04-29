import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

class CityChip extends StatelessWidget {
  final String cityName;
  final VoidCallback onTap;

  const CityChip({super.key, required this.cityName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4, vertical: 6.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryOrange, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryOrange, size: 14),
            const SizedBox(width: 4),
            Text(
              cityName,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
