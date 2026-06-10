import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pmpml/pmpml_live_bus_model.dart';
import 'pmpml_providers_setup.dart';

/// Selected route ID for the live map screen.
final selectedRouteIdProvider = StateProvider<String?>((ref) => null);

/// Polling-based live buses for a given [routeId].
/// Returns empty list if [routeId] is null (no filter selected).
final pmpmlLiveBusesProvider =
    FutureProvider.family<List<PmpmlLiveBusModel>, String>((ref, routeId) async {
  final repo = ref.watch(pmpmlRepositoryProvider);
  final result = await repo.getLiveBuses(routeId);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});

/// Live buses for all selected route, auto-polling every 15s via
/// [AsyncValue.refresh]. The screen calls [ref.invalidate] on a Timer.
final pmpmlAllLiveBusesProvider =
    FutureProvider<List<PmpmlLiveBusModel>>((ref) async {
  final routeId = ref.watch(selectedRouteIdProvider);
  if (routeId == null || routeId.isEmpty) return [];
  final repo = ref.watch(pmpmlRepositoryProvider);
  final result = await repo.getLiveBuses(routeId);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});
