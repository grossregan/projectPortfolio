import 'dart:async';
import 'dart:collection';

import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/views/alarm_ring_page.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

final logger = Logger();

enum RepeatingAlarmAction { set, stop }

class AlarmsModel {
  final AlarmsPresenter alarmConnect;

  final alarms = FirebaseFirestore.instance.collection('alarms');

  static StreamSubscription<AlarmSet>? ringSubscription;
  static StreamSubscription<AlarmSet>? scheduleSubscription;
  static StreamSubscription<int>? stopSubscription;

  bool _initialized = false;
  bool get initialized => _initialized;

  AlarmsModel({required this.alarmConnect});

  Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    logger.i('Initializing alarms model');
    await Alarm.init();
    logger.i('Alarm initialized');

    await checkNotificationPermission().then(
      (_) => checkAndroidScheduleExactAlarmPermission(),
    );

    ringSubscription ??= Alarm.ringing.listen(
      (AlarmSet alarms) => ringingCallback(alarms, context),
    );
    scheduleSubscription ??= Alarm.scheduled.listen(scheduledCallback);
    stopSubscription ??= Alarm.stopped.listen(stoppedCallback);
    logger.i('Alarm ringing and update subscription initialized');

    // TODO: synchronize firebase and device alarms
  }

  void dispose() async {
    if (!_initialized) return;
    logger.i('Destroying alarms model');
    ringSubscription?.cancel();
    scheduleSubscription?.cancel();
    ringSubscription = null;
    scheduleSubscription = null;
    _initialized = false;
    logger.i('Alarm model destroyed');
  }

  static Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      logger.i('Requesting notification permission...');
      final res = await Permission.notification.request();
      logger.i('Notification permission ${res.isGranted ? '' : 'not '}granted');
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    if (!Alarm.android) return;
    final status = await Permission.scheduleExactAlarm.status;
    logger.i('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      logger.i('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      logger.i(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  /// Callback for when an alarm is ringing.
  Future<void> ringingCallback(AlarmSet alarmSet, BuildContext context) async {
    if (alarmSet.alarms.isEmpty) return;
    final alarm = await getAlarm(alarmSet.alarms.first.id);
    if (alarm == null) return;
    logger.i('Alarm ringing: ${alarm.id}');

    // this only sometimes works lol
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) =>
                  AlarmRingPage(alarm: alarm, alarmConnect: alarmConnect),
          fullscreenDialog: true,
        ),
      );
    }
  }

  /// Callback for when alarms are scheduled or updated.
  Future<void> scheduledCallback(AlarmSet alarmSet) async {
    if (alarmSet.alarms.isEmpty) return;
    logger.i('Alarm updated: ${alarmSet.alarms.first.id}');
    // reload alarms list when alarms are created, deleted, or changed.
    alarmConnect.loadAlarms();
  }

  /// Callback for when an alarm is stopped.
  /// If the alarm is repeating, it will be rescheduled for the next week.
  /// If the alarm is not repeating, it will be deleted from the database.
  Future<void> stoppedCallback(int alarmId) async {
    if (alarmId < 0) return;
    final alarm = await alarmConnect.getAlarm(alarmId);
    if (alarm == null) return;

    logger.e('Alarm stopped: ${alarmLog(alarm)}');
    alarmConnect.reSetOrDelete(alarm);
  }

  /// Returns a reference to the Firestore document for the alarm with the given timestamp ID.
  DocumentReference getAlarmRef(int timestampId) {
    return alarms.doc(timestampId.toString());
  }

  /// Returns a string representation of the alarm for logging.
  String alarmLog(NamedAlarm alarm, {int? timestampId, List<dynamic>? extra}) {
    extra = extra ?? [];
    return [alarm.name, timestampId ?? alarm.id, ...extra].join(' / ');
  }

  /// Retrieves an alarm from Firestore using the timestamp ID.
  Future<NamedAlarm?> getAlarm(int timestampId) async {
    final DocumentSnapshot alarmSnap = await getAlarmRef(timestampId).get();
    if (alarmSnap.exists) {
      final alarm = NamedAlarm.fromJson(
        alarmSnap.data() as Map<String, dynamic>,
      );
      logger.i('Alarm retrieved: ${alarmLog(alarm)}');
      return alarm;
    } else {
      logger.w('No alarm found with ID: $timestampId');
      return null;
    }
  }

  /// Retrieves an alarm from the device using the timestamp ID.
  Future<NamedAlarm?> getDeviceAlarm(int timestampId) async {
    final alarm = await Alarm.getAlarm(timestampId);
    if (alarm == null) {
      return null;
    }
    return NamedAlarm.upgrade(
      alarm,
      name: alarm.notificationSettings.title,
      description: alarm.notificationSettings.body,
      enabled: true,
      repeatDays: [], // meh
    );
  }

  /// Retrieves all alarms from Firestore.
  /// If no alarms are found, an empty list is returned.
  /// If an error occurs, it is logged and an empty list is returned.
  /// The alarms are sorted by date and time.
  /// Returns a list of [NamedAlarm] objects.
  Future<List<NamedAlarm>> getAlarms() async {
    final QuerySnapshot snapshot = await alarms.get();

    if (snapshot.docs.isEmpty) {
      logger.w('No alarms found');
      return [];
    }

    logger.i('Alarms retrieved: ${snapshot.docs.length}');
    final fetchedAlarms =
        snapshot.docs
            .map(
              (doc) => NamedAlarm.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();
    fetchedAlarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return fetchedAlarms;
  }

  /// Handles setting or stopping repeating alarms.
  /// If the alarm is not repeating, this method does nothing.
  Future<void> handleRepeatingAlarm(
    NamedAlarm alarm, {
    required RepeatingAlarmAction action,
  }) async {
    if (!alarm.isRepeating) return;
    final now = DateTime.now().add(const Duration(seconds: 1));
    final callback = action == RepeatingAlarmAction.set ? setAlarm : stopAlarm;
    for (final (index, day) in alarm.repeatDays.indexed) {
      // skip if the alarm is not set for that day
      logger.i('Alarm $index: ${day ? 'on' : 'off'}');
      if (!day) continue;
      // get difference between day of week - current day of week (mod 7 to make Sunday = 0)
      int diff = index - (now.weekday % 7);
      if (diff < 0 || (diff == 0 && now.isAfter(alarm.dateTime))) {
        // if the alarm time is in the past, make it next week
        diff += 7;
      }
      logger.i('Alarm $index: diff = $diff');
      callback(
        alarm.withTime(alarm.dateTime.add(Duration(days: diff))),
      ).catchError(
        (e) => logger.w(
          'Alarm ${alarmLog(alarm)} failed to ${action.name} on device for day $index: $e',
        ),
      );
    }
  }

  Future<void> setAlarm(final NamedAlarm alarm) async {
    return await Alarm.set(alarmSettings: alarm)
        .then((_) => logger.i('Alarm set on device: ${alarmLog(alarm)}'))
        .catchError(
          (e) => logger.w('Alarm not set on device: ${alarmLog(alarm)} / $e'),
        );
  }

  Future<bool> createAlarm(final NamedAlarm alarm) async {
    final existingAlarm = await getAlarm(alarm.id);
    if (existingAlarm != null) {
      logger.w(
        'Alarm with ID (timestamp) ${alarm.id} already exists (${existingAlarm.name}); try edit instead',
      );
      return false;
    }

    if (alarm.enabled) {
      if (alarm.isRepeating) {
        await handleRepeatingAlarm(alarm, action: RepeatingAlarmAction.set);
      } else {
        await setAlarm(alarm);
      }
    }

    await getAlarmRef(alarm.id)
        .set(alarm.toJson())
        .then(
          (_) => logger.i('Alarm created in Firestore: ${alarmLog(alarm)}'),
        );
    return true;
  }

  Future<bool> editAlarm({
    required final int timestampId,
    required final NamedAlarm newAlarm,
  }) async {
    logger.i('Deleting old alarm');
    final deleted = await deleteAlarm(timestampId);
    if (deleted == null) {
      logger.w('No alarm with ID $timestampId found to edit; try creating');
      return false;
    }
    if (newAlarm.isInPast) {
      logger.w('Alarm date is in the past; not re-setting');
      return false;
    }
    // set the new alarm
    await createAlarm(newAlarm)
        .then((res) => logger.i('Alarm edited: ${alarmLog(newAlarm)}'))
        .catchError(
          (e) => logger.w('Alarm not edited: ${alarmLog(newAlarm)} / $e'),
        );
    return true;
  }

  Future<void> stopAlarm(final NamedAlarm alarm) async {
    return await Alarm.stop(alarm.id)
        .then((_) => logger.i('Alarm stopped on device: ${alarmLog(alarm)}'))
        .catchError(
          (e) =>
              logger.w('Alarm not stopped on device: ${alarmLog(alarm)} / $e'),
        );
  }

  Future<NamedAlarm?> deleteAlarm(int timestampId, {bool stop = true}) async {
    final alarm =
        await getAlarm(timestampId) ?? await getDeviceAlarm(timestampId);
    if (alarm == null) {
      logger.w('No alarm with ID $timestampId found to delete');
      return alarm;
    }

    if (stop) {
      if (alarm.isRepeating) {
        await handleRepeatingAlarm(alarm, action: RepeatingAlarmAction.stop);
      } else {
        await stopAlarm(alarm);
      }
    }

    await getAlarmRef(timestampId).delete().then(
      (_) => logger.i('Alarm deleted from Firestore: ${alarmLog(alarm)}'),
    );
    return alarm;
  }
}
