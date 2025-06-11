import 'dart:async';

import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlarmRingPage extends StatefulWidget {
  final AlarmsPresenter alarmConnect;
  final NamedAlarm alarm;

  const AlarmRingPage({
    super.key,
    required this.alarm,
    required this.alarmConnect,
  });

  @override
  State<AlarmRingPage> createState() => _AlarmRingPageState();
}

class _AlarmRingPageState extends State<AlarmRingPage> {
  StreamSubscription<AlarmSet>? _ringingSubscription;

  @override
  void initState() {
    super.initState();
    _ringingSubscription = Alarm.ringing.listen((alarms) {
      if (alarms.containsId(widget.alarm.id)) return;
      logger.i('Alarm ${widget.alarm.id} stopped ringing.');
      _ringingSubscription?.cancel();
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(context: context, title: 'Alarm Ringing'),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // widget.alarmConnect.stopAlarm(widget.alarm);
            widget.alarmConnect.reSetOrDelete(widget.alarm);
            logger.i('Alarm ${widget.alarm.id} has been stopped.');
          },
          child: Text('Stop Alarm'),
        ),
      ),
    );
  }
}
