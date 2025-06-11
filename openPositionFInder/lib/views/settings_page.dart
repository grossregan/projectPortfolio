import 'package:cs_3541_final_project/presenters/settings_presenter.dart';
import 'package:cs_3541_final_project/views/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension Inversion on Color {
  Color invert() => Color.fromRGBO(
        (255 - r * 255).toInt(),
        (255 - g * 255).toInt(),
        (255 - b * 255).toInt(),
        a,
      );
}

class SettingsPage extends StatelessWidget {
  final SettingsPresenter settingsPresenter;
  const SettingsPage({super.key, required this.settingsPresenter});

  Widget themePreview(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      body: GridView.count(
        crossAxisCount: 2,
        children: {
          'primary': colorScheme.primary,
          'on primary': colorScheme.onPrimary,
          'primary container': colorScheme.primaryContainer,
          'on primary container': colorScheme.onPrimaryContainer,
          'primary fixed': colorScheme.primaryFixed,
          'primary fixed dim': colorScheme.primaryFixedDim,
          'on primary fixed': colorScheme.onPrimaryFixed,
          'on primary fixed variant': colorScheme.onPrimaryFixedVariant,
          'secondary': colorScheme.secondary,
          'on secondary': colorScheme.onSecondary,
          'secondary container': colorScheme.secondaryContainer,
          'on secondary container': colorScheme.onSecondaryContainer,
          'secondary fixed': colorScheme.secondaryFixed,
          'secondary fixed dim': colorScheme.secondaryFixedDim,
          'on secondary fixed': colorScheme.onSecondaryFixed,
          'on secondary fixed variant': colorScheme.onSecondaryFixedVariant,
          'tertiary': colorScheme.tertiary,
          'on tertiary': colorScheme.onTertiary,
          'tertiary container': colorScheme.tertiaryContainer,
          'on tertiary container': colorScheme.onTertiaryContainer,
          'tertiary fixed': colorScheme.tertiaryFixed,
          'tertiary fixed dim': colorScheme.tertiaryFixedDim,
          'on tertiary fixed': colorScheme.onTertiaryFixed,
          'on tertiary fixed variant': colorScheme.onTertiaryFixedVariant,
          'error': colorScheme.error,
          'on error': colorScheme.onError,
          'error container': colorScheme.errorContainer,
          'on error container': colorScheme.onErrorContainer,
          'surface': colorScheme.surface,
          'on surface': colorScheme.onSurface,
          'surface dim': colorScheme.surfaceDim,
          'surface bright': colorScheme.surfaceBright,
          'surface container lowest': colorScheme.surfaceContainerLowest,
          'surface container low': colorScheme.surfaceContainerLow,
          'surface container': colorScheme.surfaceContainer,
          'surface container high': colorScheme.surfaceContainerHigh,
          'surface container highest': colorScheme.surfaceContainerHighest,
          'on surface variant': colorScheme.onSurfaceVariant,
          'outline': colorScheme.outline,
          'outline variant': colorScheme.outlineVariant,
          'shadow': colorScheme.shadow,
          'scrim': colorScheme.scrim,
          'inverse surface': colorScheme.inverseSurface,
          'on inverse surface': colorScheme.onInverseSurface,
          'inverse primary': colorScheme.inversePrimary,
          'surface tint': colorScheme.surfaceTint,
        }
            .entries
            .map(
              (clr) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: ColoredBox(
                      color: clr.value,
                      child: Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '${clr.key}\n',
                            style: TextStyle(
                              inherit: false,
                              fontSize: 20,
                              color: colorScheme.onPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: clr.key,
                                style: TextStyle(
                                  color: colorScheme.onPrimary.invert(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Card themeModeDropdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("Theme Mode", style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton(
              value: settingsPresenter.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System"),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
              ],
              onChanged: (mode) =>
                  settingsPresenter.changeSettings(themeMode: mode!),
            ),
          ],
        ),
      ),
    );
  }

  Widget themeColorButton(BuildContext context, Color color) {
    BoxBorder? border;
    Icon? checked;
    final currentColor = settingsPresenter.themeColor;
    final schemedColor = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    ).inversePrimary;

    if (color == currentColor) {
      Color hlClr = schemedColor.invert();
      border = Border.all(width: 2, color: hlClr);
      checked = Icon(Icons.check, color: hlClr);
    }

    return GestureDetector(
      onTap: () => settingsPresenter.changeSettings(themeColor: color),
      onLongPress: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            final scheme = ColorScheme.fromSeed(
              seedColor: color,
              brightness: Theme.of(context).brightness,
            );
            return Scaffold(
              appBar: CommonAppBar(
                context: context,
                title: "Theme Preview",
                backgroundColor: scheme.inversePrimary,
              ),
              body: Center(child: themePreview(scheme)),
            );
          },
        ),
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: schemedColor,
          borderRadius: BorderRadius.circular(8),
          shape: BoxShape.rectangle,
          border: border,
        ),
        child: checked,
      ),
    );
  }

  Card colorModeSelect(BuildContext context) {
    final colors = [
      settingsPresenter.systemColor,
      Colors.red,
      Colors.redAccent,
      Colors.deepOrange,
      Colors.deepOrangeAccent,
      Colors.orange,
      Colors.orangeAccent,
      Colors.amber,
      Colors.amberAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.lime,
      Colors.limeAccent,
      Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.green,
      Colors.greenAccent,
      Colors.teal,
      Colors.tealAccent,
      Colors.cyan,
      Colors.cyanAccent,
      Colors.lightBlue,
      Colors.lightBlueAccent,
      Colors.blue,
      Colors.blueAccent,
      Colors.indigo,
      Colors.indigoAccent,
      Colors.deepPurple,
      Colors.deepPurpleAccent,
      Colors.purple,
      Colors.purpleAccent,
      Colors.pink,
      Colors.pinkAccent,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ].where((clr) => !Colors.accents.contains(clr)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Theme Color", style: Theme.of(context).textTheme.bodyLarge),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              children: colors
                  .map(
                    (color) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: themeColorButton(context, color),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // IconButton profileButton(BuildContext context) {
  //   return IconButton(
  //     icon: const Icon(Icons.person),
  //     tooltip: "Profile",
  //     onPressed: () => Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => Scaffold(
  //           appBar: CommonAppBar(
  //             context: context,
  //             title: 'Profile',
  //           ),
  //           body: const ProfileScreen(),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void showDataCredit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Credit'),
        content: Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Software Engineer Jobs and Salaries 2024'),
              subtitle: const Text('Emre Öksüz | Kaggle'),
              trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => launchUrl(Uri.parse(
                      'https://kaggle.com/datasets/emreksz/software-engineer-jobs-and-salaries-2024/data')))),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Jobs and Salaries in Data Science'),
            subtitle: const Text('Hummaam Qaasim | Kaggle'),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => launchUrl(Uri.parse(
                  'https://www.kaggle.com/datasets/hummaamqaasim/jobs-in-data')),
            ),
          ),
        ])),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: "Settings",
        actions: const [
          // profileButton(context)
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  themeModeDropdown(context),
                  colorModeSelect(context),
                  // const SignOutButton(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      child: const Text('View Licenses'),
                      onPressed: () => showLicensePage(context: context)),
                  TextButton(
                      child: const Text('Data Credit'),
                      onPressed: () => showDataCredit(
                            context,
                          )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
