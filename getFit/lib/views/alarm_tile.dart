import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/views/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

var logger = Logger();

class AlarmTile extends StatefulWidget {
  final NamedAlarm alarm;
  final BuildContext listContext;
  final Future<void> Function() onChange;
  final AlarmsPresenter alarmConnect;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.listContext,
    required this.onChange,
    required this.alarmConnect,
  });

  @override
  State<AlarmTile> createState() => _AlarmTileState();
}

class _AlarmTileState extends State<AlarmTile> {
  bool enabled = true;
  @override
  void initState() {
    super.initState();
    enabled = widget.alarm.enabled;
  }

  void editAlarm(BuildContext context) async {
    await widget.alarmConnect.visitAlarmEditor(context, oldAlarm: widget.alarm);

    widget.onChange();
    if (context.mounted) {
      CommonSnackBar(
        theme: Theme.of(context),
        text: 'Alarm edited',
      ).show(context);
    }
  }

  void deleteAlarm() async {
    widget.alarmConnect
        .deleteAlarm(widget.alarm.id)
        .then((_) => widget.onChange());

    CommonSnackBar(
      theme: Theme.of(context),
      text: 'Alarm deleted',
      onUndoPressed:
          widget.alarm.isInPast
              ? null
              : () async {
                await widget.alarmConnect
                    .createAlarm(widget.alarm)
                    .then((alm) => widget.onChange());
                logger.i(widget.listContext.mounted);
                if (widget.listContext.mounted) {
                  CommonSnackBar(
                    theme: Theme.of(widget.listContext),
                    text: 'Alarm restored',
                  ).show(widget.listContext);
                }
              },
    ).show(context);
  }

  Switch get toggleEnabledSwitch => Switch(
    value: enabled,
    onChanged: (value) async {
      setState(() {
        enabled = value;
      });
      widget.alarmConnect
          .editAlarm(
            timestampId: widget.alarm.id,
            newAlarm: widget.alarm.copyWith(enabled: value),
          )
          .then((edited) {
            widget.onChange();
            if (!edited && mounted) {
              CommonSnackBar(
                theme: Theme.of(context),
                text: 'Alarm deleted',
              ).show(context);
            }
          });
      CommonSnackBar(
        theme: Theme.of(context),
        text: 'Alarm ${value ? 'enabled' : 'disabled'}',
      ).show(context);
    },
  );

  @override
  Widget build(BuildContext context) {
    logger.i('AlarmTile ${widget.alarm.id} built');
    return Dismissible(
      key: ValueKey(widget.alarm.id),
      onDismissed: (_) => deleteAlarm(),
      child: GestureDetector(
        onTap: () => editAlarm(context),
        child: Card(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.9),
          child: ListTile(
            leading: Icon(Icons.alarm),
            title: Text(
              '${widget.alarm.notificationSettings.title}\n${NamedAlarm.formatTime(widget.alarm.nextRingTime)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Delete alarm',
                  onPressed: deleteAlarm,
                ),
                Tooltip(
                  message: '${enabled ? 'Dis' : 'En'}able alarm',
                  child: toggleEnabledSwitch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
