import 'package:agile_avengers_get_fit/models/home_model.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/presenters/settings_presenter.dart';
import 'package:agile_avengers_get_fit/views/alarms_page.dart';
import 'package:agile_avengers_get_fit/views/exercise_view.dart';
import 'package:agile_avengers_get_fit/views/inspiration_page.dart';
import 'package:agile_avengers_get_fit/views/settings_page.dart';
import 'package:agile_avengers_get_fit/views/stat_view.dart';
import 'package:flutter/material.dart';

class HomePresenter {
  List<HomeModel> getTabs({
    required AlarmsPresenter alarmConnect,
    required SettingsPresenter settingsPresenter,
  }) {
    return [
      HomeModel(
        title: "Exercises",
        icon: Icons.fitness_center,
        screen: ExercisePage(),
      ),

      HomeModel(
        title: "Alarms",
        icon: Icons.alarm,
        screen: AlarmsPage(alarmConnect: alarmConnect),
      ),

      HomeModel(title: "Stats", icon: Icons.bar_chart, screen: StatView()),

      HomeModel(
        title: "Inspiration",
        icon: Icons.question_mark,
        screen: InspirationPage(),
      ),
      HomeModel(
        title: "Settings",
        icon: Icons.settings,
        screen: SettingsPage(settingsPresenter: settingsPresenter),
      ),
    ];
  }
}
