import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/timetable.dart';
import 'city_provider.dart';
import 'providers_setup.dart';

// ── Timetable for a specific route ────────────────────────────────────────────
final timetableProvider =
    FutureProvider.family<Timetable, String>((ref, routeId) async {
  final city = ref.watch(selectedCityProvider);
  if (city == null) throw Exception('No city selected');

  final useCase = ref.read(getRouteTimetableUseCaseProvider);
  final result = await useCase.call(city.id, routeId);
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (t) => t,
  );
});

// ── Selected day type tab ─────────────────────────────────────────────────────
final selectedDayTypeProvider =
    StateProvider<DayType>((ref) => DayType.weekday);

// ── Filtered stops for selected day ──────────────────────────────────────────
final timetableStopsProvider =
    Provider.family<List<TimetableStop>, String>((ref, routeId) {
  final day = ref.watch(selectedDayTypeProvider);
  final timetableAsync = ref.watch(timetableProvider(routeId));
  return timetableAsync.maybeWhen(
    data: (t) => t.stopsFor(day),
    orElse: () => [],
  );
});

// ── Offline download trigger ──────────────────────────────────────────────────
final downloadTimetableProvider =
    FutureProvider.family<void, String>((ref, routeId) async {
  final city = ref.watch(selectedCityProvider);
  if (city == null) throw Exception('No city selected');

  final repo = ref.read(routeRepositoryProvider);
  final result = await repo.downloadTimetableOffline(city.id, routeId);
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (_) {},
  );
});
