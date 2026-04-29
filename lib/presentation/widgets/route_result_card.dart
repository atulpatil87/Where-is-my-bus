import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'route_badge.dart';
import 'bus_type_chip.dart';
import 'crowd_indicator.dart';

class RouteResultCard extends StatelessWidget {
  final bool isDirect;
  final String duration;
  final String price;
  final String from;
  final String to;
  final String routeNum1;
  final String? routeNum2;
  final BusType busType;
  final String stats;
  final String walkInfo;
  final CrowdLevel crowdLevel;
  final String? badgeText;

  const RouteResultCard({
    super.key,
    required this.isDirect,
    required this.duration,
    required this.price,
    required this.from,
    required this.to,
    required this.routeNum1,
    this.routeNum2,
    required this.busType,
    required this.stats,
    required this.walkInfo,
    required this.crowdLevel,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: isDirect ? AppColors.busOnTime.withOpacity(0.1) : AppColors.busDelayed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  isDirect ? "DIRECT" : "1 CHANGE",
                  style: TextStyle(
                    color: isDirect ? AppColors.busOnTime : AppColors.busDelayed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                ],
              )
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(from),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
              ),
              Text(to),
            ],
          ),
          if (!isDirect) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text("1 Change at Shivajinagar", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              RouteBadge(routeNumber: routeNum1),
              if (routeNum2 != null) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.arrow_forward, size: 14),
                const SizedBox(width: AppSpacing.xs),
                RouteBadge(routeNumber: routeNum2!),
              ],
              const SizedBox(width: AppSpacing.sm),
              BusTypeChip(type: busType),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(stats, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(walkInfo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              CrowdIndicator(level: crowdLevel),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (badgeText != null) 
                Text(badgeText!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              if (badgeText == null) const SizedBox(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryOrange),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: const Row(
                  children: [
                    Text("Track Route", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryOrange),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
