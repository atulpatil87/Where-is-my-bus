import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/city_model.dart';
import '../../models/timetable_model.dart';

/// Local Hive-based cache for city data (TTL: 24h).
class CityLocalDataSource {
  static const String _boxName = 'cities_cache';
  static const String _key = 'all_cities';
  static const int _ttlHours = 24;

  Future<List<CityModel>> getCachedCities() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final json = box.get(_key);
      if (json == null) throw const CacheException(message: 'Not cached.');
      final meta = box.get('${_key}_meta');
      if (meta != null) {
        final cachedAt = DateTime.parse(meta);
        if (DateTime.now().difference(cachedAt).inHours >= _ttlHours) {
          throw const CacheException(message: 'Cache expired.');
        }
      }
      final list = jsonDecode(json) as List;
      return list
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: e.toString());
    }
  }

  Future<void> cacheCities(List<CityModel> cities) async {
    final box = await Hive.openBox<String>(_boxName);
    final json = jsonEncode(cities.map((c) => c.toJson()).toList());
    await box.put(_key, json);
    await box.put('${_key}_meta', DateTime.now().toIso8601String());
  }

  Future<void> saveSelectedCityId(String cityId) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put('selected_city', cityId);
  }

  Future<String?> getSelectedCityId() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.get('selected_city');
  }
}

/// Local Hive-based storage for offline timetables.
class TimetableLocalDataSource {
  static const String _boxName = 'timetables';

  Future<void> saveTimetable(TimetableModel timetable) async {
    final box = await Hive.openBox<String>(_boxName);
    final key = '${timetable.cityId}_${timetable.routeId}';
    await box.put(key, jsonEncode(timetable.toJson()));
    await box.put('${key}_meta', DateTime.now().toIso8601String());
  }

  Future<TimetableModel?> getTimetable(String cityId, String routeId) async {
    final box = await Hive.openBox<String>(_boxName);
    final key = '${cityId}_$routeId';
    final json = box.get(key);
    if (json == null) return null;
    return TimetableModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> deleteTimetable(String cityId, String routeId) async {
    final box = await Hive.openBox<String>(_boxName);
    final key = '${cityId}_$routeId';
    await box.delete(key);
    await box.delete('${key}_meta');
  }
}
