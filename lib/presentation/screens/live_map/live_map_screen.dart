import 'package:flutter/material.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/bus_marker_card.dart';
import 'package:busindia/presentation/widgets/bus_type_chip.dart';
import 'package:busindia/presentation/widgets/crowd_indicator.dart';
import 'package:busindia/presentation/screens/tower_tracking/tower_tracking_screen.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
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
