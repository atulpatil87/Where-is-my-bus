import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/route_result_card.dart';
import 'package:busindia/presentation/widgets/bus_type_chip.dart';
import 'package:busindia/presentation/widgets/crowd_indicator.dart';
import '../../providers/pmpml_directions_provider.dart';
import '../../providers/pmpml_routes_provider.dart';
import '../../../data/models/pmpml/pmpml_stop_model.dart';
import '../../../data/models/pmpml/pmpml_direction_model.dart';

class RouteFinderScreen extends ConsumerStatefulWidget {
  const RouteFinderScreen({super.key});

  @override
  ConsumerState<RouteFinderScreen> createState() => _RouteFinderScreenState();
}

class _RouteFinderScreenState extends ConsumerState<RouteFinderScreen> {
  @override
  Widget build(BuildContext context) {
    final directionsState = ref.watch(pmpmlDirectionsProvider);
    final fromStop = ref.watch(fromStopProvider);
    final toStop = ref.watch(toStopProvider);

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
                BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    offset: const Offset(0, 4),
                    blurRadius: 16)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FROM",
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openStopSearch(context, true),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location,
                          color: AppColors.accentBlue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            fromStop?.stopName ?? "Tap to select starting stop",
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w500,
                                color: fromStop == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    const Divider(height: 24),
                    GestureDetector(
                      onTap: () {
                        final from = ref.read(fromStopProvider);
                        final to = ref.read(toStopProvider);
                        ref.read(fromStopProvider.notifier).state = to;
                        ref.read(toStopProvider.notifier).state = from;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(Icons.swap_vert,
                            size: 16, color: AppColors.primaryOrange),
                      ),
                    ),
                  ],
                ),
                Text("TO",
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openStopSearch(context, false),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            toStop?.stopName ?? "Where to?",
                            style: AppTextStyles.body.copyWith(
                                color: toStop == null
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: fromStop != null && toStop != null
                        ? () => ref.read(pmpmlDirectionsProvider.notifier).findRoute()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                    ),
                    child: directionsState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text("Find Route",
                            style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Results Section
          Expanded(
            child: _buildResultsSection(directionsState),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(PmpmlDirectionsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_off, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.errorMessage ?? "Error finding route",
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasResult) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.map, size: 48, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text("Select stops and tap Find Route",
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final result = state.result!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Suggested Route",
                style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        RouteResultCard(
          isDirect: result.isDirect,
          duration: "${result.totalDurationMins} mins",
          price: "₹${result.totalFare}",
          from: result.steps.firstWhere((s) => s.isBus, orElse: () => result.steps.first).fromStop ?? "Start",
          to: result.steps.lastWhere((s) => s.isBus, orElse: () => result.steps.last).toStop ?? "End",
          routeNum1: result.routeNumbers.isNotEmpty ? result.routeNumbers.first : "Walk",
          routeNum2: result.routeNumbers.length > 1 ? result.routeNumbers[1] : null,
          busType: BusType.nonAc, // Would need more API data to know for sure
          stats: "${result.totalDistanceMeters ~/ 1000} km",
          walkInfo: "${result.walkingMins} min walk",
          crowdLevel: CrowdLevel.medium, // Default
          badgeText: "Recommended 🏆",
        ),
      ],
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
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _openStopSearch(BuildContext context, bool isFrom) async {
    final stop = await showSearch<PmpmlStopModel?>(
      context: context,
      delegate: _StopSearchDelegate(ref),
    );
    if (stop != null) {
      if (isFrom) {
        ref.read(fromStopProvider.notifier).state = stop;
      } else {
        ref.read(toStopProvider.notifier).state = stop;
      }
    }
  }
}

class _StopSearchDelegate extends SearchDelegate<PmpmlStopModel?> {
  final WidgetRef ref;

  _StopSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => "Search bus stop...";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final stops = ref.watch(pmpmlStopSearchProvider(query));

    if (stops.isEmpty) {
      return Center(
        child: Text("No stops found", style: AppTextStyles.body),
      );
    }

    return ListView.builder(
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: AppColors.primaryOrange),
          title: Text(stop.stopName, style: AppTextStyles.body),
          subtitle: Text("Routes: ${stop.routeIds.take(5).join(', ')}${stop.routeIds.length > 5 ? '...' : ''}",
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          onTap: () => close(context, stop),
        );
      },
    );
  }
}
