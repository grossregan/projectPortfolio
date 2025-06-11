import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/presenters/home_presenter.dart';
import 'package:agile_avengers_get_fit/presenters/settings_presenter.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final alarmConnect = AlarmsPresenter();
  final SettingsPresenter settingsPresenter;
  final Function(int) changeCurrentIndex;
  final int initialIndex;
  HomeView({
    super.key,
    required this.settingsPresenter,
    required this.changeCurrentIndex,
    this.initialIndex = 0,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomePresenter presenter = HomePresenter();

  @override
  void dispose() {
    widget.alarmConnect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.alarmConnect.init(context);
    final tabs = presenter.getTabs(
      alarmConnect: widget.alarmConnect,
      settingsPresenter: widget.settingsPresenter,
    );
    final theme = Theme.of(context);
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: tabs.length,
      child: Scaffold(
        backgroundColor: theme.colorScheme.inversePrimary,
        body: TabBarView(children: tabs.map((btn) => btn.screen).toList()),
        bottomNavigationBar: TabBar(
          onTap: (value) => widget.changeCurrentIndex(value),
          tabs:
              tabs
                  .map(
                    (tab) => Padding(
                      padding: const EdgeInsets.only(bottom: 15, top: 5),
                      child: Tooltip(
                        message: tab.title,
                        child: Tab(icon: Icon(tab.icon, size: 30)),
                      ),
                    ),
                  )
                  .toList(),

          labelColor: theme.colorScheme.onPrimaryContainer,
          indicatorColor: theme.colorScheme.onPrimaryContainer,
          unselectedLabelColor: theme.unselectedWidgetColor,
          // indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 4,
          indicatorPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
