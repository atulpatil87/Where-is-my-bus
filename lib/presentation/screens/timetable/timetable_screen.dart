import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, 2), blurRadius: 8)
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search route number or name...",
                        prefixIcon: Icon(LucideIcons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                
                // Saved Routes Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Saved Routes", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                      Text("Browse All Routes", style: AppTextStyles.caption.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Saved Routes Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      _buildSavedRouteCard("155", "Swargate - Hinjewadi", [AppColors.primaryOrange, AppColors.primaryOrangeDark]),
                      _buildSavedRouteCard("11", "Swargate - Katraj", [AppColors.accentBlue, Colors.blue.shade800]),
                      _buildSavedRouteCard("4A", "Shivajinagar - Baner", [AppColors.accentGreen, Colors.green.shade800]),
                    ],
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Divider(),
                ),
              ],
            ),
          ),
          
          // Selected Route Detail Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryOrange, AppColors.primaryOrangeDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryOrange.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Route 155", style: AppTextStyles.heading.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("Swargate → Hinjewadi Phase 1", style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn("33 Stops"),
                        _buildInfoColumn("First: 5:30 AM"),
                        _buildInfoColumn("Last: 11:00 PM"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn("Freq: Every 12 mins"),
                        _buildInfoColumn("Fare: ₹10–₹35"),
                        const SizedBox(width: 40), // spacer
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Day Type Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: const [
                          Tab(text: "Weekday"),
                          Tab(text: "Saturday"),
                          Tab(text: "Sunday"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Timeline
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTimelineItem(context, "Swargate", "05:30", "₹0", true, true),
                _buildTimelineItem(context, "Pune Station", "05:38", "₹5", false, false),
                _buildTimelineItem(context, "Shivajinagar", "05:45", "₹8", false, false),
                _buildTimelineItem(context, "FC Road", "05:50", "₹10", true, false),
                _buildTimelineItem(context, "Baner Phata", "06:05", "₹15", false, false),
                _buildTimelineItem(context, "Balewadi", "06:12", "₹18", false, false),
                _buildTimelineItem(context, "Hinjewadi Phase 1", "06:20", "₹22", true, false),
                _buildTimelineItem(context, "Hinjewadi Phase 2", "06:28", "₹28", true, false),
                _buildTimelineItem(context, "Hinjewadi Phase 3", "06:35", "₹35", true, false, isLast: true),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download),
                label: const Text("Save Timetable for Offline Use"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(color: AppColors.primaryOrange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLarge)),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildSavedRouteCard(String routeNum, String routeName, List<Color> gradient) {
    return Container(
      width: 120,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(routeNum, style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 24)),
              Text(routeName, style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          const Positioned(
            top: -4,
            right: -4,
            child: Icon(Icons.star, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String text) {
    return Row(
      children: [
        Container(
          width: 4, height: 4,
          decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String station, String time, String fare, bool isMajor, bool isFirst, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : AppColors.primaryOrange,
                ),
                Container(
                  width: isMajor ? 12 : 8,
                  height: isMajor ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isMajor ? AppColors.primaryOrange : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryOrange, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      station,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: isMajor ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.divider.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(fare, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
