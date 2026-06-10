import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/domain/entities/location_fix.dart';
import 'package:busindia/presentation/providers/bluetooth_location_provider.dart';
import 'package:busindia/presentation/widgets/bus_marker_card.dart';
import 'package:busindia/presentation/widgets/bus_type_chip.dart';
import 'package:busindia/presentation/widgets/crowd_indicator.dart';
import 'package:busindia/presentation/screens/tower_tracking/tower_tracking_screen.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final List<String> _filters = ["All Routes", "AC Only", "Non-AC", "Electric", "On Time", "Crowded"];
  String _selectedFilter = "All Routes";

  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.01) {
        setState(() {
          _currentScale = scale;
        });
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLocation = ref.watch(effectiveLocationProvider);

    return Stack(
      children: [
        // Map Placeholder with zoom/pan support
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Container(
            color: const Color(0xFFE8F5E9),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Dummy Bus Markers
                _buildMapMarker(context, top: 150, left: 50, route: "11", color: AppColors.busOnTime),
                _buildMapMarker(context, top: 250, left: 180, route: "4A", color: AppColors.busDelayed),
                _buildMapMarker(context, top: 400, left: 100, route: "155", color: AppColors.busCrowded),
                _buildMapMarker(context, top: 300, left: 300, route: "24", color: AppColors.busOnTime),

                // "You are here" marker, resolved from GPS or a nearby
                // Bluetooth peer when GPS is off.
                effectiveLocation.maybeWhen(
                  data: (fix) => _buildSelfMarker(context, fix: fix),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        // Floating Top Elements
        SafeArea(
          child: Column(
            children: [
              // Top Card
              Container(
                margin: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.16), offset: const Offset(0, 4), blurRadius: 16)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.busOnTime.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: const Text("🚌 24 Buses Live", style: TextStyle(color: AppColors.busOnTime, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Text("Last updated: 2s ago", style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ),

              // Location source indicator (GPS vs Bluetooth fallback)
              effectiveLocation.maybeWhen(
                data: (fix) => fix.isFromBluetooth
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _LocationSourceBanner(fix: fix),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryOrange : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(color: isSelected ? Colors.transparent : AppColors.divider),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Bottom Sliding Panel
        DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.15,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, -4), blurRadius: 16)
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          Text("Nearby Buses", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: const Text("3", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: Row(
                        children: const [
                          BusMarkerCard(routeNumber: "11", busType: BusType.nonAc, routeName: "Swargate - Katraj", etaMinutes: 2, crowdLevel: CrowdLevel.medium),
                          BusMarkerCard(routeNumber: "4A", busType: BusType.ac, routeName: "Shivajinagar - Baner", etaMinutes: 5, crowdLevel: CrowdLevel.low),
                          BusMarkerCard(routeNumber: "155", busType: BusType.electric, routeName: "Pune Stn - Hinjewadi", etaMinutes: 12, crowdLevel: CrowdLevel.high),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // FAB
        Positioned(
          bottom: 150,
          right: AppSpacing.md,
          child: FloatingActionButton.extended(
            onPressed: () => _showShareOptions(context),
            backgroundColor: AppColors.primaryOrange,
            icon: const Icon(Icons.directions_bus, color: Colors.white),
            label: const Text("I'm on a Bus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text("Share your bus", style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.cell_tower, color: AppColors.primaryOrange),
                title: const Text("Track via cell tower"),
                subtitle: const Text("Works without GPS — saves battery & data"),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TowerTrackingScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.gps_fixed, color: AppColors.accentBlue),
                title: const Text("Share GPS location"),
                subtitle: const Text("Most precise — requires GPS on"),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelfMarker(BuildContext context, {required LocationFix fix}) {
    final color = fix.isFromBluetooth ? AppColors.primaryOrange : AppColors.accentBlue;
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 1), blurRadius: 2)
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  fix.isFromBluetooth ? Icons.bluetooth_connected : Icons.gps_fixed,
                  size: 10,
                  color: color,
                ),
                const SizedBox(width: 4),
                const Text("You", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(BuildContext context, {required double top, required double left, required String route, required Color color}) {
    // Scale marker content inversely to zoom so markers stay readable but
    // also provide a subtle size cue — clamped to avoid extremes.
    final inverseScale = (1.0 / _currentScale).clamp(0.5, 1.5);
    final iconSize = 14.0 * inverseScale;
    final fontSize = 12.0 * inverseScale;
    final hPad = 8.0 * inverseScale;
    final vPad = 4.0 * inverseScale;
    final borderRadius = 8.0 * inverseScale;

    return Positioned(
      top: top,
      left: left,
      child: Transform.scale(
        scale: inverseScale,
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border(left: BorderSide(color: color, width: 4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 4)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_bus, size: iconSize, color: AppColors.textPrimary),
              SizedBox(width: 4 * inverseScale),
              Text(route, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown over the map when the resolved position came from a nearby
/// Bluetooth peer instead of GPS.
class _LocationSourceBanner extends StatelessWidget {
  final LocationFix fix;
  const _LocationSourceBanner({required this.fix});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        border: Border.all(color: Colors.amber.shade600, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_connected, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'GPS off — your position is approximated from a nearby '
              'commuter\'s location (~${fix.accuracy.round()} m accuracy).',
              style: const TextStyle(fontSize: 11, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}
