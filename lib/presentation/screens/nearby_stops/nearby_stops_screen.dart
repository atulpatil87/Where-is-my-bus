import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/stop_nearby_card.dart';
import '../../providers/pmpml_routes_provider.dart';

class NearbyStopsScreen extends ConsumerStatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  ConsumerState<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends ConsumerState<NearbyStopsScreen> {
  String _selectedSort = "Nearest";

  @override
  Widget build(BuildContext context) {
    // For a real app, this would use a LocationProvider to get actual lat/lng
    // and pass it to a nearby stops provider. Since we don't have location yet,
    // we'll just display a slice of the global stops list as "nearby".
    final stopsAsync = ref.watch(pmpmlStopsProvider);

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
                            _buildSortChip(context, "Nearest"),
                            _buildSortChip(context, "Most Routes"),
                            _buildSortChip(context, "Next Bus Soon"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: stopsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Error: $e")),
                    data: (stops) {
                      if (stops.isEmpty) {
                        return const Center(child: Text("No stops found"));
                      }
                      
                      // Sort based on selection (simulated for Nearest/Next Bus)
                      final displayStops = List.of(stops);
                      if (_selectedSort == "Most Routes") {
                        displayStops.sort((a, b) => b.routeIds.length.compareTo(a.routeIds.length));
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        itemCount: displayStops.take(20).length,
                        itemBuilder: (context, index) {
                          final stop = displayStops[index];
                          final distMeters = 150 + (index * 120);
                          final walkMins = (distMeters / 80).ceil();
                          return StopNearbyCard(
                            stopName: stop.stopName,
                            distanceStr: "${distMeters}m · $walkMins min walk 🚶",
                            routes: stop.routeIds.take(4).toList(),
                            nextBusMinute: (index % 15) + 1,
                          );
                        },
                      );
                    },
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

  Widget _buildSortChip(BuildContext context, String label) {
    final isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = label),
      child: Container(
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
      ),
    );
  }
}
