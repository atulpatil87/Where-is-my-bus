import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import '../../providers/pmpml_routes_provider.dart';
import '../../../data/models/pmpml/pmpml_route_model.dart';
import '../../../data/models/pmpml/pmpml_stop_model.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  String _searchQuery = "";
  PmpmlRouteModel? _selectedRoute;

  @override
  Widget build(BuildContext context) {
    final routesSearch = ref.watch(pmpmlRouteSearchProvider(_searchQuery));

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
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Search route number or name...",
                        prefixIcon: Icon(LucideIcons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                
                // Show search results if searching
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: ListView.builder(
                        itemCount: routesSearch.length,
                        itemBuilder: (context, index) {
                          final route = routesSearch[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(route.routeNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                            ),
                            title: Text(route.routeLongName, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text("Freq: ${route.frequencyMins} mins"),
                            onTap: () {
                              setState(() {
                                _selectedRoute = route;
                                _searchQuery = "";
                              });
                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
                      ),
                    ),
                  )
                else ...[
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
                ],
                
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Divider(),
                ),
              ],
            ),
          ),
          
          // Selected Route Detail
          if (_selectedRoute != null) ...[
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
                      Text("Route ${_selectedRoute!.routeNumber}", style: AppTextStyles.heading.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(_selectedRoute!.routeLongName, style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn("${_selectedRoute!.stopIds.length} Stops"),
                          _buildInfoColumn("First: ${_selectedRoute!.firstBusTime}"),
                          _buildInfoColumn("Last: ${_selectedRoute!.lastBusTime}"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn("Freq: Every ${_selectedRoute!.frequencyMins} mins"),
                          _buildInfoColumn("Fare: ₹${_selectedRoute!.fareMin}–₹${_selectedRoute!.fareMax}"),
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

            // Timeline (Stops)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: _buildStopsList(),
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
          ] else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(LucideIcons.map, size: 48, color: AppColors.divider),
                      const SizedBox(height: AppSpacing.md),
                      Text("Search for a route to view its timetable", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildStopsList() {
    final route = _selectedRoute!;
    
    // We display stops embedded in route if available, otherwise just ids
    if (route.stops.isNotEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stop = route.stops[index];
            final isFirst = index == 0;
            final isLast = index == route.stops.length - 1;
            final isMajor = isFirst || isLast || index % 5 == 0;
            
            // Simulating schedule times since we don't fetch full schedule here
            final minutes = index * 3;
            final time = "06:${minutes.toString().padLeft(2, '0')}";
            
            return _buildTimelineItem(context, stop.stopName, time, isMajor, isFirst, isLast: isLast);
          },
          childCount: route.stops.length,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stopId = route.stopIds[index];
            final isFirst = index == 0;
            final isLast = index == route.stopIds.length - 1;
            
            return _buildTimelineItem(context, "Stop ID: $stopId", "--:--", false, isFirst, isLast: isLast);
          },
          childCount: route.stopIds.length,
        ),
      );
    }
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

  Widget _buildTimelineItem(BuildContext context, String station, String time, bool isMajor, bool isFirst, {bool isLast = false}) {
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
