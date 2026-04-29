import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

class RouteBadge extends StatelessWidget {
  final String routeNumber;

  const RouteBadge({super.key, required this.routeNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        routeNumber,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
