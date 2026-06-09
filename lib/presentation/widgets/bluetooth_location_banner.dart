import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/bluetooth_location_provider.dart';

/// Compact card that shows the Bluetooth location mesh status and lets the
/// user toggle it on/off. Drop this widget anywhere a location context exists
/// (e.g. LiveMap screen, NearbyStops screen, ProfileScreen settings).
class BluetoothLocationBanner extends ConsumerWidget {
  /// If provided, these coords are used to seed the BLE advertisement when
  /// GPS is unavailable (e.g. user manually selected their city).
  final double? seedLat;
  final double? seedLng;

  const BluetoothLocationBanner({
    super.key,
    this.seedLat,
    this.seedLng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesh = ref.watch(bluetoothMeshProvider);
    final notifier = ref.read(bluetoothMeshProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _bgColor(mesh.status, context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: _borderColor(mesh.status),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          _StatusIcon(status: mesh.status),
          const SizedBox(width: AppSpacing.sm),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(mesh.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(mesh),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          // Toggle / action button
          _ActionButton(
            status: mesh.status,
            onStart: () => notifier.start(
              fallbackLat: seedLat,
              fallbackLng: seedLng,
            ),
            onStop: notifier.stop,
          ),
        ],
      ),
    );
  }

  Color _bgColor(BluetoothMeshStatus status, BuildContext context) {
    switch (status) {
      case BluetoothMeshStatus.active:
        return AppColors.primaryOrange.withOpacity(0.08);
      case BluetoothMeshStatus.error:
        return AppColors.accentRed.withOpacity(0.07);
      default:
        return Theme.of(context).cardColor;
    }
  }

  Color _borderColor(BluetoothMeshStatus status) {
    switch (status) {
      case BluetoothMeshStatus.active:
        return AppColors.primaryOrange.withOpacity(0.4);
      case BluetoothMeshStatus.error:
        return AppColors.accentRed.withOpacity(0.4);
      default:
        return AppColors.divider;
    }
  }

  String _title(BluetoothMeshStatus status) {
    switch (status) {
      case BluetoothMeshStatus.idle:
        return 'Bluetooth Location Sharing';
      case BluetoothMeshStatus.starting:
        return 'Starting Bluetooth Mesh…';
      case BluetoothMeshStatus.active:
        return 'Bluetooth Mesh Active';
      case BluetoothMeshStatus.error:
        return 'Bluetooth Unavailable';
    }
  }

  String _subtitle(BluetoothMeshState mesh) {
    switch (mesh.status) {
      case BluetoothMeshStatus.idle:
        return 'Help others when GPS is off — share your location via Bluetooth.';
      case BluetoothMeshStatus.starting:
        return 'Enabling BLE advertising & scanning…';
      case BluetoothMeshStatus.active:
        final count = mesh.peers.length;
        return count == 0
            ? 'Broadcasting your location. No peers found yet.'
            : '$count nearby commuter${count == 1 ? '' : 's'} detected via Bluetooth.';
      case BluetoothMeshStatus.error:
        return mesh.errorMessage ?? 'Check Bluetooth permissions in Settings.';
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final BluetoothMeshStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == BluetoothMeshStatus.starting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryOrange,
        ),
      );
    }
    return Icon(
      Icons.bluetooth,
      size: 20,
      color: _iconColor(status),
    );
  }

  Color _iconColor(BluetoothMeshStatus status) {
    switch (status) {
      case BluetoothMeshStatus.active:
        return AppColors.primaryOrange;
      case BluetoothMeshStatus.error:
        return AppColors.accentRed;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final BluetoothMeshStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _ActionButton({
    required this.status,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (status == BluetoothMeshStatus.starting) {
      return const SizedBox.shrink();
    }

    final isActive = status == BluetoothMeshStatus.active;
    return TextButton(
      onPressed: isActive ? onStop : onStart,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: isActive
            ? AppColors.accentRed.withOpacity(0.1)
            : AppColors.primaryOrange.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
      child: Text(
        isActive ? 'Stop' : 'Enable',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color:
              isActive ? AppColors.accentRed : AppColors.primaryOrange,
        ),
      ),
    );
  }
}

/// Compact card showing a single discovered Bluetooth peer.
class BluetoothPeerTile extends StatelessWidget {
  final double lat;
  final double lng;
  final double accuracy;
  final double speedKmh;
  final int rssi;
  final double estimatedDistanceMeters;

  const BluetoothPeerTile({
    super.key,
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.speedKmh,
    required this.rssi,
    required this.estimatedDistanceMeters,
  });

  @override
  Widget build(BuildContext context) {
    final distText = estimatedDistanceMeters < 1000
        ? '~${estimatedDistanceMeters.round()} m away'
        : '~${(estimatedDistanceMeters / 1000).toStringAsFixed(1)} km away';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_circle,
              color: AppColors.primaryOrange, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}  '
                  '· ${speedKmh.round()} km/h',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${rssi} dBm',
            style: TextStyle(
              fontSize: 10,
              color:
                  Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
