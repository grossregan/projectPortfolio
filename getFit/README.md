# agile_avengers_get_fit

agile_avengers_get_fit is a multi-platform Flutter application scaffolded with Firebase support. It contains platform-specific runners (Android, iOS, macOS, Linux, Windows, Web) and example integration with Firebase (see `lib/firebase_options.dart` and `firebase.json`). It is a prototype build of an application that would allow users to track and build workouts, keep a history of their workouts, lifts, and records, and visualize their progress on a graph.

## Quick summary

- Framework: Flutter (multi-platform)
- Firebase: integrated (see `firebase.json` and `lib/firebase_options.dart`)
- Platforms targeted: Android, iOS, macOS, web (project contains platform folders)

This README explains how to set up the project locally, run it on different platforms, run tests, and where to look in the codebase.

## Prerequisites

- Git
- Flutter SDK (stable channel). Use the version compatible with your environment. To check: `flutter --version`.
- Platform tooling for targets you intend to run (Android Studio / Android SDK for Android, Xcode + CocoaPods for iOS/macOS, browser for web).
- (Optional) Firebase project & CLI if you will modify Firebase configuration or deploy cloud functions.

Note: The project already contains `firebase.json` and `lib/firebase_options.dart` (generated). If you need to connect to your own Firebase project, regenerate or replace the options file accordingly.

## Setup

1. Clone the repository (if you haven't already):

```bash
git clone <repository-url>
cd project
```

2. Install Dart/Flutter dependencies:

```bash
flutter pub get
```

3. Platform-specific setup:

- Android: install Android SDK / Android Studio. Ensure a device or emulator is available.
- iOS/macOS: install Xcode and CocoaPods (`sudo gem install cocoapods`), then run `pod install` inside the generated iOS/macOS workspace if needed.
- Web: ensure a supported browser (Chrome recommended for `flutter run -d chrome`).

4. Firebase: If you want to use your own Firebase project, either replace `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` and regenerate `lib/firebase_options.dart` using `flutterfire` CLI, or update the existing configs with your project values.

## Running the app

Run for the default connected device:

```bash
flutter run
```

Run on a specific device or emulator (example for Android emulator):

```bash
flutter devices                # list available devices
flutter run -d <deviceId>
```

Run for web (Chrome):

```bash
flutter run -d chrome
```

Build release artifacts:

```bash
flutter build apk             # Android
flutter build ios             # iOS (requires macOS and Xcode)
flutter build macos           # macOS
flutter build web             # Web
```


## Troubleshooting

- If you see problems with CocoaPods on macOS/iOS, try `pod repo update` and then `flutter clean` followed by `flutter pub get`.
- If Firebase fails to initialize, confirm `lib/firebase_options.dart` matches your Firebase console project and that native config files (google-services.json / GoogleService-Info.plist) are present for Android/iOS respectively.
- If the Flutter SDK version is incompatible, run `flutter --version` and consider switching channels or upgrading Flutter: `flutter upgrade`.

## Contributing

This was a group project!! My contributions are as follows:
- The main screen & the API that sources the exercises
- The favorites algorithm and dedicated favorites page
- The custom light & dark mode UI coloring for he respective pages.

## License & credits

This project template does not include a specific license file. If you plan to publish or share the code, add a `LICENSE` file at the repository root and mention the license here.

---

