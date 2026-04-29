import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

enum BusType { ac, nonAc, electric, mini }

class BusTypeChip extends StatelessWidget {
  final BusType type;

  const BusTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (type) {
      case BusType.ac:
        color = AppColors.accentBlue;
        label = "AC";
        break;
      case BusType.nonAc:
        color = AppColors.textSecondary;
        label = "Non-AC";
        break;
      case BusType.electric:
        color = AppColors.accentGreen;
        label = "Electric";
        break;
      case BusType.mini:
        color = Colors.deepPurple;
        label = "Mini";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
