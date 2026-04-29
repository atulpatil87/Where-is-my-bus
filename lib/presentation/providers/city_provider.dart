import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/city.dart';
import 'providers_setup.dart';

// ── All cities for City Selection Screen ────────────────────────────────────
final allCitiesProvider = FutureProvider<List<City>>((ref) async {
  final useCase = ref.read(getCitiesUseCaseProvider);
  final result = await useCase.call();
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (cities) => cities,
  );
});

// ── Auto-detect city on Splash Screen ───────────────────────────────────────
final detectCityProvider = FutureProvider<City>((ref) async {
  final useCase = ref.read(detectCityUseCaseProvider);
  final result = await useCase.call();
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (city) => city,
  );
});

// ── Currently selected city (global state) ──────────────────────────────────
final selectedCityProvider =
    StateNotifierProvider<SelectedCityNotifier, City?>((ref) {
  return SelectedCityNotifier(ref);
});

class SelectedCityNotifier extends StateNotifier<City?> {
  final Ref _ref;
  SelectedCityNotifier(this._ref) : super(null);

  void selectCity(City city) {
    state = city;
    _ref.read(cityRepositoryProvider).saveSelectedCity(city.id);
  }

  Future<void> loadSavedCity() async {
    final result = await _ref.read(detectCityUseCaseProvider).call();
    result.fold((_) {}, (city) => state = city);
  }
}
