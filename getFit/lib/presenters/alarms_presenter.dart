import 'package:agile_avengers_get_fit/models/alarms_model.dart';
import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/views/alarm_editor.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlarmsPresenter {
  late AlarmsModel _alarmsModel;
  List<NamedAlarm> _alarms = [];
  List<NamedAlarm> get alarms => _alarms;
  void Function(Function())? _setStateFn;

  AlarmsPresenter() {
    _alarmsModel = AlarmsModel(alarmConnect: this);
    loadAlarms();
  }

  void setStateFn(final void Function(Function()) fn) {
    _setStateFn = fn;
  }

  Future<void> loadAlarms() async {
    logger.i('Loading alarms');
    final alarmData = await getAlarms();
    for (final oldAlarm in alarmData.where((alarm) => alarm.isInPast)) {
      logger.w('Alarm ${oldAlarm.id} is in past, deleting from firebase');
      await deleteAlarm(oldAlarm.id, stop: false);
    }
    if (_setStateFn == null) {
      _alarms = alarmData;
    } else {
      _setStateFn!(() => _alarms = alarmData);
    }
  }

  Future<void> init(BuildContext context) async {
    return await _alarmsModel.init(context);
  }

  void dispose() {
    return _alarmsModel.dispose();
  }

  Future<void> visitAlarmEditor(
    BuildContext context, {
    final NamedAlarm? oldAlarm,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: AlarmEditor(alarm: oldAlarm, alarmConnect: this),
        );
      },
    ).then((_) => loadAlarms());
  }

  Future<NamedAlarm?> getAlarm(int timestampId) async {
    return await _alarmsModel.getAlarm(timestampId);
  }

  Future<List<NamedAlarm>> getAlarms() async {
    return await _alarmsModel.getAlarms();
  }

  Future<bool> createAlarm(final NamedAlarm alarm) async {
    return await _alarmsModel.createAlarm(alarm);
  }

  Future<bool> editAlarm({
    required final int timestampId,
    required final NamedAlarm newAlarm,
  }) async {
    return await _alarmsModel.editAlarm(
      timestampId: timestampId,
      newAlarm: newAlarm,
    );
  }

  Future<NamedAlarm?> deleteAlarm(
    final int timestampId, {
    bool stop = true,
  }) async {
    return await _alarmsModel.deleteAlarm(timestampId, stop: stop);
  }

  /// If the alarm is repeating, set it to the next week.
  /// If the alarm is not repeating, delete it from the database.
  Future<void> reSetOrDelete(NamedAlarm alarm) async {
    logger.i('Re-setting or deleting alarm ${alarm.id}');
    if (alarm.isRepeating) {
      logger.i('Alarm ${alarm.id} is repeating, setting it to next week');
      // edit is expensive. i'm using it because I want the tile to accurately reflect the next-ring-time
      // await _alarmsModel.editAlarm(
      //   timestampId: alarm.id,
      //   newAlarm: alarm.withTime(alarm.dateTime.add(const Duration(days: 7))),
      // );
      await _alarmsModel.setAlarm(
        alarm.withTime(alarm.dateTime.add(const Duration(days: 7))),
      );
      await _alarmsModel.stopAlarm(alarm);
    } else if (alarm.isInPast) {
      logger.i('Alarm ${alarm.id} is in past, deleting it');
      await _alarmsModel.deleteAlarm(alarm.id);
    }
    loadAlarms();
  }

  Future<void> stopAlarm(NamedAlarm alarm) async {
    logger.i('Stopping alarm ${alarm.id}');
    return await _alarmsModel.stopAlarm(alarm);
  }
}
