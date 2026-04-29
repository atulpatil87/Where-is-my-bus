import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/route_result_card.dart';
import 'package:busindia/presentation/widgets/bus_type_chip.dart';
import 'package:busindia/presentation/widgets/crowd_indicator.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RouteFinderScreen extends StatelessWidget {
  const RouteFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Input Section
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.16), offset: const Offset(0, 4), blurRadius: 16)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FROM", style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.my_location, color: AppColors.accentBlue, size: 18),
                    const SizedBox(width: 8),
                    Text("My Location", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.swap_vert, size: 16, color: AppColors.primaryOrange),
                    ),
                  ],
                ),
                Text("TO", style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text("Where to?", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text("Today, 9:00 AM", style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Smart Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _buildSmartChip(context, "🏥 Hospital"),
                _buildSmartChip(context, "🏫 College"),
                _buildSmartChip(context, "🛒 Market"),
                _buildSmartChip(context, "🏢 IT Park"),
                _buildSmartChip(context, "🚉 Station"),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("3 Routes Found", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                const Icon(Icons.sort, color: AppColors.textSecondary),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),

          // Results Scroll
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                const RouteResultCard(
                  isDirect: true,
                  duration: "35 mins",
                  price: "₹15",
                  from: "Swargate",
                  to: "Hinjewadi Phase 1",
                  routeNum1: "155",
                  busType: BusType.ac,
                  stats: "12 stops",
                  walkInfo: "4 min walk",
                  crowdLevel: CrowdLevel.medium,
                  badgeText: "Fastest 🏆",
                ),
                
                // AI Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrangeLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.primaryOrangeLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("🤖", style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "AI Tip: Route 155 is 20% more crowded on Fridays. Leave before 8:30 AM for a comfortable ride.",
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrangeDark),
                        ),
                      ),
                    ],
                  ),
                ),

                const RouteResultCard(
                  isDirect: false,
                  duration: "48 mins",
                  price: "₹20",
                  from: "Swargate",
                  to: "Hinjewadi Phase 1",
                  routeNum1: "11",
                  routeNum2: "4A",
                  busType: BusType.nonAc,
                  stats: "18 stops",
                  walkInfo: "6 min walk",
                  crowdLevel: CrowdLevel.high,
                ),

                const RouteResultCard(
                  isDirect: true,
                  duration: "52 mins",
                  price: "₹15",
                  from: "Swargate",
                  to: "Hinjewadi Phase 1",
                  routeNum1: "16LE",
                  busType: BusType.electric,
                  stats: "22 stops",
                  walkInfo: "2 min walk",
                  crowdLevel: CrowdLevel.low,
                  badgeText: "Least Crowded 🌿",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
