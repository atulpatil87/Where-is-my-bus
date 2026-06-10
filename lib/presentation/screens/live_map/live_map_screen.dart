import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:busindia/core/theme/app_colors.dart';
import 'package:busindia/core/theme/app_spacing.dart';
import 'package:busindia/core/theme/app_text_styles.dart';
import 'package:busindia/presentation/widgets/bus_marker_card.dart';
import 'package:busindia/presentation/widgets/bus_type_chip.dart';
import 'package:busindia/presentation/widgets/crowd_indicator.dart';
import '../../providers/pmpml_auth_provider.dart';
import '../../providers/pmpml_live_buses_provider.dart';
import '../../providers/pmpml_routes_provider.dart';
import '../../providers/pmpml_providers_setup.dart';
import '../pmpml_login/pmpml_otp_screen.dart';
import '../../../data/models/pmpml/pmpml_live_bus_model.dart';
import '../../../data/models/pmpml/pmpml_route_model.dart';
import 'package:busindia/presentation/screens/tower_tracking/tower_tracking_screen.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final List<String> _filters = [
    'All Routes', 'AC Only', 'Non-AC', 'Electric', 'On Time'
  ];
  String _selectedFilter = 'All Routes';
  final MapController _mapController = MapController();
  Timer? _pollTimer;
  String? _selectedRouteId;
  LatLng? _userLocation;
  bool _isLocating = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    // Auto-poll live positions every 15s. When a single route is selected we
    // refresh just that route; otherwise we refresh the city-wide view.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        if (!mounted) return;
        if (_selectedRouteId != null) {
          ref.invalidate(pmpmlLiveBusesProvider(_selectedRouteId!));
        } else {
          ref.read(cityLiveBusesProvider.notifier).refresh();
        }
      },
    );
    // Try to resolve location on open so the map can centre on nearby buses.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolveInitialLocation();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(pmpmlAuthProvider);
    final routesAsync = ref.watch(pmpmlRoutesProvider);

    // Decide which buses to show. With no route selected we show the
    // city-wide "live buses near you" view (no login required); selecting a
    // route narrows it to just that route.
    final liveBusesAsync = _selectedRouteId != null
        ? ref.watch(pmpmlLiveBusesProvider(_selectedRouteId!))
        : ref.watch(cityLiveBusesProvider);

    // Stamp the "last updated" time whenever fresh data arrives.
    ref.listen<AsyncValue<List<PmpmlLiveBusModel>>>(
      _selectedRouteId != null
          ? pmpmlLiveBusesProvider(_selectedRouteId!)
          : cityLiveBusesProvider,
      (prev, next) {
        if (next.hasValue && mounted) {
          setState(() => _lastUpdated = DateTime.now());
        }
      },
    );

    final buses = liveBusesAsync.valueOrNull ?? [];
    final filteredBuses = _applyFilter(buses);

    return Stack(
      children: [
        // ── Map area ────────────────────────────────────────────────────────
        _buildMapArea(context, filteredBuses),

        // ── Floating top UI ──────────────────────────────────────────────────
        SafeArea(
          child: Column(
            children: [
              // Live status banner (live count + last updated)
              _buildTopBanner(context, liveBusesAsync, filteredBuses.length),

              // Route selector — optional filter, available to everyone
              const SizedBox(height: AppSpacing.xs),
              _buildRouteSelector(context, routesAsync),
              const SizedBox(height: AppSpacing.xs),

              // Filter chips
              _buildFilterChips(context),
            ],
          ),
        ),

        // ── Bottom sliding panel ─────────────────────────────────────────────
        DraggableScrollableSheet(
          initialChildSize: 0.28,
          minChildSize: 0.12,
          maxChildSize: 0.65,
          builder: (ctx, scrollCtrl) =>
              _buildBottomPanel(ctx, scrollCtrl, filteredBuses, liveBusesAsync),
        ),

        // ── My Location FAB ──────────────────────────────────────────────────
        Positioned(
          bottom: 220,
          right: AppSpacing.md,
          child: FloatingActionButton(
            heroTag: 'my_location_fab',
            onPressed: _isLocating ? null : () => _goToMyLocation(context),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 4,
            tooltip: 'My Location',
            child: _isLocating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryOrange),
                    ),
                  )
                : Icon(
                    _userLocation != null
                        ? Icons.my_location
                        : Icons.location_searching,
                    color: _userLocation != null
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
          ),
        ),

        // ── Share FAB ────────────────────────────────────────────────────────
        Positioned(
          bottom: 160,
          right: AppSpacing.md,
          child: FloatingActionButton.extended(
            heroTag: 'share_bus_fab',
            onPressed: () => authState.isAuthenticated
                ? _showShareOptions(context)
                : _openLogin(context),
            backgroundColor: AppColors.primaryOrange,
            icon: const Icon(Icons.directions_bus, color: Colors.white),
            label: const Text("I'm on a Bus",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Map area ───────────────────────────────────────────────────────────────

  Widget _buildMapArea(BuildContext context, List<PmpmlLiveBusModel> buses) {
    // Default center for Pune
    const centerLatLng = LatLng(18.5204, 73.8567);

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: centerLatLng,
        initialZoom: 13.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.busindia',
        ),
        MarkerLayer(
          markers: buses
              .where((b) => b.lat != 0 || b.lng != 0)
              .map((bus) {
            return Marker(
              point: LatLng(bus.lat, bus.lng),
              width: 86,
              height: 44,
              child: GestureDetector(
                onTap: () => _showBusDetails(context, bus),
                child: _buildMapMarker(
                  context,
                  route: bus.routeNumber.isEmpty ? bus.busId : bus.routeNumber,
                  color: _busColor(bus),
                  heading: bus.heading,
                ),
              ),
            );
          }).toList(),
        ),

        // ── User location marker ─────────────────────────────────────────────
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                width: 48,
                height: 48,
                child: _buildUserLocationMarker(),
              ),
            ],
          ),
      ],
    );
  }

  // ── Top banner ─────────────────────────────────────────────────────────────

  Widget _buildTopBanner(
    BuildContext context,
    AsyncValue<List<PmpmlLiveBusModel>> liveBusesAsync,
    int busCount,
  ) {
    final isLoading = liveBusesAsync.isLoading;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.busOnTime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              '🚌 $busCount Buses Live',
              style: const TextStyle(
                  color: AppColors.busOnTime,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          Text(
            _lastUpdatedLabel(),
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                  ),
                )
              : GestureDetector(
                  onTap: _refreshLiveBuses,
                  child: const Icon(Icons.refresh,
                      size: 20, color: AppColors.textSecondary),
                ),
        ],
      ),
    );
  }

  String _lastUpdatedLabel() {
    if (_lastUpdated == null) return 'Live';
    final secs = DateTime.now().difference(_lastUpdated!).inSeconds;
    if (secs < 5) return 'Updated just now';
    if (secs < 60) return 'Updated ${secs}s ago';
    final mins = secs ~/ 60;
    return 'Updated ${mins}m ago';
  }

  void _refreshLiveBuses() {
    if (_selectedRouteId != null) {
      ref.invalidate(pmpmlLiveBusesProvider(_selectedRouteId!));
    } else {
      ref.read(cityLiveBusesProvider.notifier).refresh();
    }
  }

  // ── Route selector ─────────────────────────────────────────────────────────

  Widget _buildRouteSelector(
      BuildContext context, AsyncValue<List<PmpmlRouteModel>> routesAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: routesAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => _buildErrorCard(e.toString()),
        data: (routes) {
          return DropdownButtonFormField<String?>(
            value: _selectedRouteId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'All live buses near you',
              prefixIcon: const Icon(Icons.route, color: AppColors.primaryOrange),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('🚍 All live buses near you',
                    overflow: TextOverflow.ellipsis),
              ),
              ...routes.map((r) => DropdownMenuItem<String?>(
                    value: r.routeId,
                    child: Text('${r.routeNumber} — ${r.routeLongName}',
                        overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (val) => setState(() => _selectedRouteId = val),
          );
        },
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange
                    : Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.divider),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom panel ───────────────────────────────────────────────────────────

  Widget _buildBottomPanel(
    BuildContext context,
    ScrollController scrollCtrl,
    List<PmpmlLiveBusModel> buses,
    AsyncValue<List<PmpmlLiveBusModel>> liveBusesAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 16)
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollCtrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text('Nearby Buses',
                      style: AppTextStyles.subHead
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      '${buses.length}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Error state
            liveBusesAsync.whenOrNull(
                  error: (e, _) => _buildErrorCard(e.toString()),
                ) ??
                const SizedBox.shrink(),

            const SizedBox(height: AppSpacing.sm),

            // Bus cards (or empty / loading state)
            if (buses.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Row(
                  children: buses
                      .map((bus) => GestureDetector(
                            onTap: () => _showBusDetails(context, bus),
                            child: BusMarkerCard(
                              routeNumber: bus.routeNumber.isEmpty
                                  ? bus.busId
                                  : bus.routeNumber,
                              busType: _busType(bus),
                              routeName: bus.routeNumber,
                              etaMinutes: bus.etaMinutes ?? 0,
                              crowdLevel: _crowdLevel(bus),
                            ),
                          ))
                      .toList(),
                ),
              )
            else
              _buildEmptyBusesState(context, liveBusesAsync.isLoading),

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showBusDetails(BuildContext context, PmpmlLiveBusModel bus) {
    final routeLabel =
        bus.routeNumber.isEmpty ? bus.busId : bus.routeNumber;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _busColor(bus).withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_bus,
                              size: 18, color: _busColor(bus)),
                          const SizedBox(width: 6),
                          Text(
                            routeLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _busColor(bus)),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    BusTypeChip(type: _busType(bus)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _detailRow(Icons.access_time, 'ETA',
                    bus.etaMinutes != null ? '${bus.etaMinutes} min' : 'N/A'),
                _detailRow(Icons.speed, 'Speed',
                    '${bus.speedKmh.toStringAsFixed(0)} km/h'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text('Crowd',
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary)),
                      const Spacer(),
                      CrowdIndicator(level: _crowdLevel(bus)),
                    ],
                  ),
                ),
                _detailRow(
                    Icons.update,
                    'Last seen',
                    _ago(bus.lastUpdated)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _ago(DateTime time) {
    final secs = DateTime.now().difference(time).inSeconds;
    if (secs < 5) return 'just now';
    if (secs < 60) return '${secs}s ago';
    final mins = secs ~/ 60;
    return '${mins}m ago';
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
              Text('Share your bus',
                  style: AppTextStyles.subHead
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading:
                    const Icon(Icons.cell_tower, color: AppColors.primaryOrange),
                title: const Text('Track via cell tower'),
                subtitle:
                    const Text('Works without GPS — saves battery & data'),
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
                leading:
                    const Icon(Icons.gps_fixed, color: AppColors.accentBlue),
                title: const Text('Share GPS location'),
                subtitle: const Text('Most precise — requires GPS on'),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(error,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBusesState(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              ),
            )
          else
            const Icon(Icons.directions_bus_outlined,
                color: AppColors.textSecondary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isLoading
                  ? 'Finding live buses near you…'
                  : 'No live buses right now. Pull to refresh or pick a route.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Map marker ─────────────────────────────────────────────────────────────

  Widget _buildMapMarker(BuildContext context,
      {required String route,
      required Color color,
      double heading = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus, size: 14, color: color),
          const SizedBox(width: 4),
          Text(route,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          if (heading != 0) ...[
            const SizedBox(width: 2),
            Transform.rotate(
              // Heading is clockwise-from-north; the arrow icon points up
              // (north) by default, so rotate by the heading in radians.
              angle: heading * math.pi / 180.0,
              child: Icon(Icons.navigation, size: 11, color: color),
            ),
          ],
        ],
      ),
    );
  }

  // ── User location marker widget ────────────────────────────────────────────

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing outer ring
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentBlue.withOpacity(0.2),
            border: Border.all(
              color: AppColors.accentBlue.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
        // Inner dot
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentBlue,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Go to my location ────────────────────────────────────────────────────────

  /// Silently resolves the user's location on screen open (only if permission
  /// is already granted) so the city-wide view can prioritise nearby routes
  /// and the map can centre on the user. Never prompts — the My Location FAB
  /// handles explicit permission requests.
  Future<void> _resolveInitialLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _userLocation = latLng);
      ref.read(userLatLngProvider.notifier).state =
          (lat: latLng.latitude, lng: latLng.longitude);
      _mapController.move(latLng, 14.0);
    } catch (_) {
      // Best-effort only — fall back to the default Pune centre.
    }
  }

  Future<void> _goToMyLocation(BuildContext context) async {
    setState(() => _isLocating = true);
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Request / check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location permission permanently denied. Enable it in Settings.'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Settings',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      // Fetch position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() => _userLocation = latLng);
        // Feed location to the city-wide view so it polls nearby routes.
        ref.read(userLatLngProvider.notifier).state =
            (lat: latLng.latitude, lng: latLng.longitude);
        _mapController.move(latLng, 15.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _openLogin(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PmpmlOtpScreen()),
    );
  }

  List<PmpmlLiveBusModel> _applyFilter(List<PmpmlLiveBusModel> buses) {
    if (_selectedFilter == 'All Routes') return buses;
    return buses.where((b) {
      final t = b.busId.toUpperCase();
      if (_selectedFilter == 'AC Only') return t.contains('AC');
      if (_selectedFilter == 'Non-AC') return !t.contains('AC');
      if (_selectedFilter == 'Electric') return t.contains('E') || t.contains('EV');
      return true;
    }).toList();
  }

  Color _busColor(PmpmlLiveBusModel bus) {
    if (bus.crowdLevel >= 3) return AppColors.busCrowded;
    if (bus.speedKmh < 5) return AppColors.busDelayed;
    return AppColors.busOnTime;
  }

  BusType _busType(PmpmlLiveBusModel bus) {
    final id = (bus.busNumber + bus.routeNumber).toUpperCase();
    if (id.contains('AC')) return BusType.ac;
    if (id.contains('EV') || id.contains('LE')) return BusType.electric;
    return BusType.nonAc;
  }

  CrowdLevel _crowdLevel(PmpmlLiveBusModel bus) {
    if (bus.crowdLevel >= 3) return CrowdLevel.high;
    if (bus.crowdLevel == 2) return CrowdLevel.medium;
    return CrowdLevel.low;
  }
}
