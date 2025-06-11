import 'package:cs_3541_final_project/presenters/settings_presenter.dart';
import 'package:cs_3541_final_project/views/home_view.dart'; // <-- adjust the path if needed
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final settingsPresenter = SettingsPresenter();
  int initialIndex = 0;

  @override
  void initState() {
    super.initState();

    settingsPresenter.init(setState: setState);
  }

  // don't need to set state because state only becomes relevant when a setting is changed at which point changeSettings sets the state
  void changeCurrentIndex(int index) => initialIndex = index;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: settingsPresenter.themeColor,
      ),
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: settingsPresenter.themeColor,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agile Avengers Final Project',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: settingsPresenter.themeMode,
      home: HomeView(
        settingsPresenter: settingsPresenter,
        changeCurrentIndex: changeCurrentIndex,
        initialIndex: initialIndex,
      ),
    );
  }
}
