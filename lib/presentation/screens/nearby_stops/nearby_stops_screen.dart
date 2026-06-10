import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/domain/entities/stop.dart';
import 'package:busindia/presentation/providers/bluetooth_location_provider.dart';
import 'package:busindia/presentation/providers/nearby_stops_provider.dart';
import 'package:busindia/presentation/widgets/stop_nearby_card.dart';

class NearbyStopsScreen extends ConsumerWidget {
  const NearbyStopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(nearbyStopsProvider);
    final locationAsync = ref.watch(effectiveLocationProvider);

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
                      locationAsync.maybeWhen(
                        data: (fix) => fix.isFromBluetooth
                            ? Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.sm),
                                child: _BluetoothLocationNotice(accuracyMeters: fix.accuracy),
                              )
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: stopsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _ErrorState(
                      message: e.toString().replaceFirst('Exception: ', ''),
                      onRetry: () => ref.invalidate(nearbyStopsProvider),
                    ),
                    data: (stops) {
                      if (stops.isEmpty) {
                        return const _EmptyStopsState();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        itemCount: stops.length,
                        itemBuilder: (context, index) {
                          final stop = stops[index];
                          return StopNearbyCard(
                            stopName: stop.name,
                            distanceStr: _formatDistance(stop),
                            routes: stop.routeIds,
                            nextBusMinute: stop.nextBus?.etaMins,
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

  String _formatDistance(Stop stop) {
    final meters = stop.distanceMeters ?? 0;
    final distanceLabel = meters >= 1000
        ? '${(meters / 1000).toStringAsFixed(1)}km'
        : '${meters.round()}m';
    final walkingMins = stop.walkingMins;
    return walkingMins != null
        ? '$distanceLabel · $walkingMins min walk 🚶'
        : distanceLabel;
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

/// Shown when stops were resolved using a nearby Bluetooth peer's location
/// instead of GPS.
class _BluetoothLocationNotice extends StatelessWidget {
  final double accuracyMeters;
  const _BluetoothLocationNotice({required this.accuracyMeters});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'GPS off — showing stops near a nearby commuter\'s location '
              '(~${accuracyMeters.round()} m accuracy).',
              style: const TextStyle(fontSize: 11, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStopsState extends StatelessWidget {
  const _EmptyStopsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus_filled_outlined,
                size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No bus stops found nearby.',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 48, color: AppColors.accentRed),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
