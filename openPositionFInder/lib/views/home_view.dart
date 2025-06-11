import 'package:cs_3541_final_project/presenters/home_presenter.dart';
import 'package:cs_3541_final_project/presenters/settings_presenter.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final SettingsPresenter settingsPresenter;
  final Function(int) changeCurrentIndex;
  final int initialIndex;

  const HomeView({
    super.key,
    required this.settingsPresenter,
    required this.changeCurrentIndex,
    required this.initialIndex,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomePresenter presenter = HomePresenter();

  @override
  Widget build(BuildContext context) {
    final tabs = presenter.getTabs(
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
          tabs: tabs
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
          indicatorWeight: 4,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
