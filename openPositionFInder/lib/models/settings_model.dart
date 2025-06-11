import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class SettingsModel {
  static ThemeMode _themeMode = ThemeMode.system;
  static Color _themeColor = Colors.blue;
  void Function(Function())? _setState;

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
