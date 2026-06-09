import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/bluetooth_peer.dart';
import '../../providers/bluetooth_location_provider.dart';
import '../../widgets/bluetooth_location_banner.dart';

/// Screen that shows all nearby Bluetooth peers and lets the user manage
/// the BLE location mesh. Accessible from the Profile settings or from
/// the bottom nav when GPS is unavailable.
class BluetoothPeersScreen extends ConsumerWidget {
  const BluetoothPeersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesh = ref.watch(bluetoothMeshProvider);
    final fallback = ref.watch(bluetoothFallbackPeerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Location Mesh'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          // How it works
          _HowItWorksCard(),

          // Toggle banner
          const BluetoothLocationBanner(),

          // GPS fallback notice
          if (fallback != null) _FallbackNotice(peer: fallback),

          // Peers list
          if (mesh.isActive) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Commuters (${mesh.peers.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (mesh.peers.isNotEmpty)
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (mesh.peers.isEmpty)
              _EmptyPeersPlaceholder()
            else
              ...mesh.peers.map((peer) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: BluetoothPeerTile(
                      lat: peer.lat,
                      lng: peer.lng,
                      accuracy: peer.accuracy,
                      speedKmh: peer.speedKmh,
                      rssi: peer.rssi,
                      estimatedDistanceMeters:
                          peer.estimatedDistanceMeters,
                    ),
                  )),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryOrangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bluetooth, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'How Bluetooth Mesh Works',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.$2,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _steps = [
    ('📡', 'Your phone broadcasts its GPS coordinates via Bluetooth LE.'),
    ('🔍', 'Nearby BusIndia devices broadcast theirs back to you.'),
    ('📍',
        'When your GPS is off, the closest peer\'s location is used as a fallback so the app still knows roughly where you are.'),
    ('🔒', 'No pairing, no internet, no server — purely local mesh.'),
  ];
}

class _FallbackNotice extends StatelessWidget {
  final BluetoothPeer peer;
  const _FallbackNotice({required this.peer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        border: Border.all(color: Colors.amber.shade600, width: 1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_searching, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'GPS off — using nearby commuter location as approximate position '
              '(~${peer.estimatedDistanceMeters.round()} m accuracy).',
              style: const TextStyle(fontSize: 11, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPeersPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.bluetooth_searching,
              size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Scanning for nearby commuters…',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
