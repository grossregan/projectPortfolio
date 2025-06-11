import 'package:cs_3541_final_project/models/settings_model.dart';
import 'package:flutter/material.dart';

class SettingsPresenter {
  final _model = SettingsModel();

  void init({required void Function(Function()) setState}) {
    _model.init(setState: setState);
  }

  ThemeMode get themeMode => _model.themeMode;
  Color get themeColor => _model.themeColor;
  Color get systemColor => _model.systemColor;

  void changeSettings({ThemeMode? themeMode, Color? themeColor}) {
    _model.changeSettings(themeMode: themeMode, themeColor: themeColor);
  }
}
