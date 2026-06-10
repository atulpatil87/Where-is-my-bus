import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_initialTheme());

  static ThemeMode _initialTheme() {
    final box = Hive.box<String>('user_prefs');
    final val = box.get('theme_mode');
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    Hive.box<String>('user_prefs').put('theme_mode', isDark ? 'dark' : 'light');
  }

  void setSystemTheme() {
    state = ThemeMode.system;
    Hive.box<String>('user_prefs').delete('theme_mode');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
