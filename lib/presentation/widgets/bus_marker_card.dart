import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'route_badge.dart';
import 'bus_type_chip.dart';
import 'eta_badge.dart';
import 'crowd_indicator.dart';

class BusMarkerCard extends StatelessWidget {
  final String routeNumber;
  final BusType busType;
  final String routeName;
  final int etaMinutes;
  final CrowdLevel crowdLevel;

  const BusMarkerCard({
    super.key,
    required this.routeNumber,
    required this.busType,
    required this.routeName,
    required this.etaMinutes,
    required this.crowdLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 100,
      margin: const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RouteBadge(routeNumber: routeNumber),
              BusTypeChip(type: busType),
            ],
          ),
          Text(
            routeName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ETABadge(minutes: etaMinutes),
              CrowdIndicator(level: crowdLevel),
            ],
          ),
        ],
      ),
    );
  }
}
