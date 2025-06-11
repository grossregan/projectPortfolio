import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class SettingsModel {
  // TODO: put this in firebase
  // final preferences  = FirebaseFirestore.instance.collection("preferences");
  // TODO: this breaks because settingsModel gets initialized before firebase does
  // TODO: make this a singleton

  static ThemeMode _themeMode = ThemeMode.system;
  static Color _themeColor = Colors.blue;
  void Function(Function())? _setState;

  SettingsModel() {
    // preferences = FirebaseFirestore.instance.collection("preferences");
  }

  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;
  Color get systemColor => SystemTheme.accentColor.accent.withAlpha(255);

  void init({required void Function(Function()) setState}) {
    _setState = setState;
    SystemTheme.fallbackColor = _themeColor;
    SystemTheme.accentColor.load().then(
      (_) => changeSettings(themeColor: systemColor),
    );
  }

  void changeSettings({ThemeMode? themeMode, Color? themeColor}) {
    _setState?.call(() {
      _themeMode = themeMode ?? _themeMode;
      _themeColor = themeColor ?? _themeColor;
    });
  }
}
