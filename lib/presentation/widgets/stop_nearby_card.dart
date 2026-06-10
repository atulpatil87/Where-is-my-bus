import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';

class StopNearbyCard extends StatelessWidget {
  final String stopName;
  final String distanceStr;
  final List<String> routes;
  final int? nextBusMinute;

  const StopNearbyCard({
    super.key,
    required this.stopName,
    required this.distanceStr,
    required this.routes,
    this.nextBusMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 2),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stopName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(distanceStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: routes.map((e) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.divider.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nextBusMinute != null ? "$nextBusMinute min" : "—",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.busOnTime),
              ),
              const Text("Next bus", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              const Icon(Icons.navigation, color: AppColors.accentBlue, size: 20),
            ],
          )
        ],
      ),
    );
  }
}
