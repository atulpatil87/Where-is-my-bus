import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/city_provider.dart';
import '../../providers/providers_setup.dart';
import '../../providers/tower_tracking_provider.dart';

/// No-GPS bus tracking — reads the serving cell tower and places the bus from a
/// crowd-sourced tower→stop map, the same way "Where is my Train" works.
class TowerTrackingScreen extends ConsumerStatefulWidget {
  const TowerTrackingScreen({super.key});

  @override
  ConsumerState<TowerTrackingScreen> createState() =>
      _TowerTrackingScreenState();
}

class _TowerTrackingScreenState extends ConsumerState<TowerTrackingScreen> {
  final _routeController = TextEditingController();

  @override
  void dispose() {
    _routeController.dispose();
    super.dispose();
  }

  String get _cityId => ref.read(selectedCityProvider)?.id ?? 'pune';

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(towerSnapshotProvider(_cityId));
    final sharing = ref.watch(towerSharingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track without GPS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _explainerCard(),
          const SizedBox(height: AppSpacing.md),
          snapshotAsync.when(
            loading: () => _loadingCard(),
            error: (e, _) => _errorCard(e.toString()),
            data: (snap) => _towerCard(snap),
          ),
          const SizedBox(height: AppSpacing.md),
          _shareSection(sharing, snapshotAsync.valueOrNull),
        ],
      ),
    );
  }

  Widget _explainerCard() {
    return Container(
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
          Row(
            children: [
              const Icon(Icons.cell_tower, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cell-tower positioning',
                style: AppTextStyles.subHead.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Works even with GPS off or no signal lock. Your phone reads the '
            'mobile tower it is connected to, and we match it to the nearest '
            'bus stop from crowd data — saving battery and data.',
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return _card(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _errorCard(String message) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.accentRed),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _towerCard(TowerSnapshot snap) {
    final cell = snap.cell;
    if (cell == null) {
      return _errorCard(snap.error ?? 'No serving cell tower detected.');
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _signalIcon(cell.signalDbm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Serving tower',
                  style: AppTextStyles.subHead
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _chip(
                cell.radioType.toUpperCase(),
                AppColors.accentBlue,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _kv('Cell ID', cell.cid?.toString() ?? '—'),
          _kv('Area (LAC/TAC)', cell.lac?.toString() ?? '—'),
          _kv('Operator', '${cell.mcc}-${cell.mnc}'),
          _kv('Signal', '${cell.signalDbm} dBm'),
          const Divider(height: AppSpacing.lg),
          _resolvedRow(snap),
        ],
      ),
    );
  }

  Widget _resolvedRow(TowerSnapshot snap) {
    if (snap.isMapped) {
      final fix = snap.fix!;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.place,
            color: fix.isTrusted ? AppColors.busOnTime : AppColors.busDelayed,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fix.nearestStopName.isEmpty
                      ? 'Mapped location'
                      : 'Near ${fix.nearestStopName}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  fix.isTrusted
                      ? 'Confident · ${fix.fingerprint.sampleCount} samples'
                      : 'Calibrating · ${fix.fingerprint.sampleCount} sample(s)',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.help_outline, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tower not mapped yet',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Be the first to calibrate it — uses one GPS fix to teach the '
                'crowd map, then future riders are located GPS-free.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _calibrate,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Calibrate this tower'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shareSection(TowerSharingState sharing, TowerSnapshot? snap) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "I'm on a bus",
            style: AppTextStyles.subHead.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Share this bus to others — its position updates from the tower, no '
            'GPS needed.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _routeController,
            enabled: !sharing.isSharing,
            decoration: InputDecoration(
              labelText: 'Route number (e.g. 11, 4A)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (sharing.error != null) ...[
            Text(
              sharing.error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.accentRed),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: sharing.isSharing
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                    ),
                    onPressed: () =>
                        ref.read(towerSharingProvider.notifier).stop(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop sharing'),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _startSharing(snap),
                    icon: const Icon(Icons.cell_tower),
                    label: const Text('Share via cell tower'),
                  ),
          ),
          if (sharing.isSharing && sharing.lastFix != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.podcasts,
                    size: 16, color: AppColors.busOnTime),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Live near ${sharing.lastFix!.nearestStopName}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.busOnTime),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startSharing(TowerSnapshot? snap) async {
    final route = _routeController.text.trim();
    if (route.isEmpty) {
      _toast('Enter your bus route number first.');
      return;
    }
    if (snap == null || !snap.isMapped) {
      _toast('This tower is not mapped yet — calibrate it first.');
      return;
    }
    await ref.read(towerSharingProvider.notifier).start(
          cityId: _cityId,
          routeId: 'route_$route',
          routeNumber: route,
        );
  }

  Future<void> _calibrate() async {
    _toast('Reading GPS once to calibrate…');
    final result =
        await ref.read(calibrateTowerUseCaseProvider).call(cityId: _cityId);
    if (!mounted) return;
    result.fold(
      (f) => _toast(f.message),
      (_) {
        _toast('Tower calibrated — thanks for contributing!');
        ref.invalidate(towerSnapshotProvider(_cityId));
      },
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ── small UI helpers ───────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style:
                  AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _signalIcon(int dbm) {
    final Color color;
    if (dbm >= -85) {
      color = AppColors.busOnTime;
    } else if (dbm >= -100) {
      color = AppColors.busDelayed;
    } else {
      color = AppColors.busCrowded;
    }
    return Icon(Icons.signal_cellular_alt, color: color);
  }
}
