import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/stop_nearby_card.dart';

class NearbyStopsScreen extends StatelessWidget {
  const NearbyStopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top Map View Placeholder
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: const Color(0xFFE3F2FD),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentBlue, width: 2),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ),
                _buildMapStopDot(context, top: 40, left: 100),
                _buildMapStopDot(context, top: 120, left: 220),
                _buildMapStopDot(context, top: 200, left: 80),
                _buildMapStopDot(context, top: 180, left: 300),
              ],
            ),
          ),

          // Scrollable List
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Bus Stops Near You", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Text("< 500m", style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrange)),
                              const Icon(Icons.arrow_drop_down, color: AppColors.primaryOrange),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip(context, "Nearest", true),
                            _buildSortChip(context, "Most Routes", false),
                            _buildSortChip(context, "Next Bus Soon", false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    children: const [
                      StopNearbyCard(
                        stopName: "Shivajinagar Bus Stand",
                        distanceStr: "200m · 2 min walk 🚶",
                        routes: ["11", "4A", "155", "16LE", "+5 more"],
                        nextBusMinute: 2,
                      ),
                      StopNearbyCard(
                        stopName: "Simla Office",
                        distanceStr: "350m · 4 min walk 🚶",
                        routes: ["24", "11", "54"],
                        nextBusMinute: 5,
                      ),
                      StopNearbyCard(
                        stopName: "Wakdewadi",
                        distanceStr: "480m · 5 min walk 🚶",
                        routes: ["4A", "155", "305"],
                        nextBusMinute: 8,
                      ),
                      StopNearbyCard(
                        stopName: "COEP Hostel",
                        distanceStr: "620m · 7 min walk 🚶",
                        routes: ["11", "305"],
                        nextBusMinute: 11,
                      ),
                      StopNearbyCard(
                        stopName: "Pune Station",
                        distanceStr: "1.1km · 12 min walk 🚶",
                        routes: ["155", "24", "16LE", "+12 more"],
                        nextBusMinute: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStopDot(BuildContext context, {required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryOrange, width: 3),
        ),
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryOrange : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: isSelected ? Colors.transparent : AppColors.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
