import 'package:agile_avengers_get_fit/presenters/settings_presenter.dart';
import 'package:agile_avengers_get_fit/views/auth_gate.dart';
import 'package:agile_avengers_get_fit/views/home_view.dart';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();
void main() {
  runApp(MyApp());
}

Future<FirebaseApp> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  return await Firebase.initializeApp();
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

    return FutureBuilder(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.e("Couldn't connect to firebase");

          return const MaterialApp(
            home: Center(child: Text('Error initializing Firebase')),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          logger.i('Firebase connected successfully');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MVP Flutter App',
            theme: theme,
            darkTheme: darkTheme,
            themeMode: settingsPresenter.themeMode,
            home: AuthGate(
              loggedInPage: HomeView(
                settingsPresenter: settingsPresenter,
                changeCurrentIndex: changeCurrentIndex,
                initialIndex: initialIndex,
              ),
            ),
          );
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [Icon(Icons.hourglass_top), Text('Loading...')],
              ),
            ),
          ),
        );
      },
    );
  }
}
