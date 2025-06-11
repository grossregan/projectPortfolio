import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/views/alarm_tile.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmsList extends StatefulWidget {
  final AlarmsPresenter alarmConnect;
  final List<NamedAlarm>? alarms;
  final Future<void> Function() onChange;
  final void Function(ScrollPosition) onScroll;

  const AlarmsList({
    super.key,
    required this.alarms,
    required this.onChange,
    required this.onScroll,
    required this.alarmConnect,
  });

  @override
  State<AlarmsList> createState() => _AlarmsListState();
}

class _AlarmsListState extends State<AlarmsList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      widget.onScroll(scrollController.position);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primaryContainer.withValues(
      alpha: 0.75,
    );
    final onCardColor = theme.colorScheme.onSurface.withValues(alpha: 0.8);
    if (widget.alarms == null || widget.alarms!.isEmpty) {
      return GestureDetector(
        onTap:
            () async => await widget.alarmConnect
                .visitAlarmEditor(context)
                .then((_) => widget.onChange()),
        onLongPress: () => Alarm.stopAll(),
        child: FullscreenCard(
          color: cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.alarm_off, size: 96, color: onCardColor),
              const SizedBox(height: 16),
              Text(
                'No Alarms',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: onCardColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.alarms!.length,
      itemBuilder: (ctx, index) {
        NamedAlarm alarm = widget.alarms![index];
        return AlarmTile(
          alarm: alarm,
          listContext: context,
          onChange: widget.onChange,
          alarmConnect: widget.alarmConnect,
        );
      },
      controller: scrollController,
      // add padding at the bottom so the FAB doesn't block buttons
      padding: const EdgeInsets.only(bottom: 80),
    );
  }
}

class FullscreenCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const FullscreenCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  color:
                      color ?? Theme.of(context).colorScheme.primaryContainer,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
