import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';

enum VolumeType { fixed, fade, staircaseFade }

extension GetVolumeType on VolumeSettings {
  VolumeType get volumeType {
    if (fadeSteps.isNotEmpty) return VolumeType.staircaseFade;
    if (fadeDuration != null) return VolumeType.fade;
    return VolumeType.fixed;
  }
}

class NamedAlarm extends AlarmSettings {
  final String name;
  final String description;
  final bool enabled;
  final List<bool> repeatDays;

  const NamedAlarm({
    required super.id,
    required this.name,
    required this.description,
    required super.dateTime,
    required super.assetAudioPath,
    required super.volumeSettings,
    required super.notificationSettings,
    this.enabled = true,
    this.repeatDays = const [false, false, false, false, false, false, false],
    super.loopAudio = true,
    super.vibrate = true,
    super.warningNotificationOnKill = true,
    super.androidFullScreenIntent = true,
    super.allowAlarmOverlap = false,
    super.iOSBackgroundAudio = true,
    super.payload,
  });

  NamedAlarm.upgrade(
    AlarmSettings alarmSettings, {
    required this.name,
    required this.description,
    required this.enabled,
    required this.repeatDays,
  }) : super(
         id: alarmSettings.id,
         dateTime: alarmSettings.dateTime,
         assetAudioPath: alarmSettings.assetAudioPath,
         volumeSettings: alarmSettings.volumeSettings,
         notificationSettings: alarmSettings.notificationSettings,
         loopAudio: alarmSettings.loopAudio,
         vibrate: alarmSettings.vibrate,
         warningNotificationOnKill: alarmSettings.warningNotificationOnKill,
         androidFullScreenIntent: alarmSettings.androidFullScreenIntent,
         allowAlarmOverlap: alarmSettings.allowAlarmOverlap,
         iOSBackgroundAudio: alarmSettings.iOSBackgroundAudio,
         payload: alarmSettings.payload,
       );

  static String formatTime(DateTime dateTime) =>
      DateFormat('LLL d yyyy, hh:mm a').format(dateTime);

  String get formattedTime => formatTime(dateTime);

  static int formatId(DateTime time) {
    return (time.millisecondsSinceEpoch / 1000).toInt();
  }

  bool get isInPast => dateTime.isBefore(DateTime.now()) && !isRepeating;
  bool get isRepeating => repeatDays.any((day) => day);

  DateTime get nextRingTime {
    DateTime response = dateTime;
    if (isRepeating) {
      response = dateTime.add(
        Duration(
          // GitHub Copilot wrote this particular algorithm
          days: repeatDays
              .asMap()
              .entries
              .where((entry) => entry.value)
              .map((entry) {
                final days = (entry.key + 1 - DateTime.now().weekday) % 7;
                return days == 0 && dateTime.isBefore(DateTime.now())
                    ? 7
                    : days;
              })
              .reduce((a, b) => a < b ? a : b),
        ),
      );
    }
    return response;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['name'] = name;
    json['description'] = description;
    json['enabled'] = enabled;
    json['repeatDays'] = repeatDays;
    return json;
  }

  factory NamedAlarm.fromJson(Map<String, dynamic> json) {
    final settings = AlarmSettings.fromJson(json);
    return NamedAlarm.upgrade(
      settings,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      enabled: json['enabled'] ?? true,
      repeatDays: List<bool>.from(json['repeatDays'] ?? [], growable: false),
    );
  }

  @override
  NamedAlarm copyWith({
    String? name,
    String? description,
    bool? enabled,
    List<bool>? repeatDays,
    int? id,
    DateTime? dateTime,
    String? assetAudioPath,
    VolumeSettings? volumeSettings,
    NotificationSettings? notificationSettings,
    bool? loopAudio,
    bool? vibrate,
    double? volume,
    bool? volumeEnforced,
    double? fadeDuration,
    List<double>? fadeStopTimes,
    List<double>? fadeStopVolumes,
    String? notificationTitle,
    String? notificationBody,
    bool? warningNotificationOnKill,
    bool? androidFullScreenIntent,
    bool? allowAlarmOverlap,
    bool? iOSBackgroundAudio,
    String? Function()? payload,
  }) {
    final settings = super.copyWith(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath,
      volumeSettings: volumeSettings,
      notificationSettings: notificationSettings,
      loopAudio: loopAudio,
      vibrate: vibrate,
      warningNotificationOnKill: warningNotificationOnKill,
      androidFullScreenIntent: androidFullScreenIntent,
      allowAlarmOverlap: allowAlarmOverlap,
      iOSBackgroundAudio: iOSBackgroundAudio,
      payload: payload,
    );
    return NamedAlarm.upgrade(
      settings,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  NamedAlarm withTime(DateTime newTime) =>
      copyWith(id: formatId(newTime), dateTime: newTime);
}
