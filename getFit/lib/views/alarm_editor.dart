import 'package:agile_avengers_get_fit/models/named_alarm.dart';
import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:weekday_selector/weekday_selector.dart';

final logger = Logger();

class AlarmEditor extends StatefulWidget {
  final NamedAlarm? alarm;
  final AlarmsPresenter alarmConnect;

  const AlarmEditor({super.key, this.alarm, required this.alarmConnect});

  @override
  State<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends State<AlarmEditor> {
  bool _editing = false;

  // input helpers/alarm attributes
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final notificationController = TextEditingController();
  bool _volumeSettingsExpanded = false;
  List<String> _alarmAudioOptions = [];

  late int _alarmId;
  late DateTime _alarmTime;
  late bool _enabled;

  late bool _vibrate;
  late String _assetAudioPath;

  late VolumeType _volumeType;
  late bool _useSystemVolume;
  late double _volume;
  // fade or staircaseFade
  late int _fadeDuration;
  // staircaseFade only
  late int _fadeStepsCount;
  // staircaseFade only
  // String _fadeDirection = 'up';

  late List<bool> _repeatDays;

  @override
  void initState() {
    super.initState();
    final alm = widget.alarm;
    final volSet = alm?.volumeSettings;
    _volumeType = volSet?.volumeType ?? VolumeType.fixed;
    // if volume is null, we are using system volume otherwise the max/fixed volume is set
    _useSystemVolume = volSet?.volume == null;
    _volume = (volSet?.volume ?? 0.01) * 100;

    _fadeDuration = volSet?.fadeDuration?.inSeconds ?? 1;

    // long story short i will be unhappy if this ever ends up less than 2
    // suffice it to say there are divide by zero errors
    _fadeStepsCount = volSet?.fadeSteps.length ?? 2;

    // we actually have to grab fade duration from the last fade step if fadeSteps are set
    // because fade duration is not provided to us by the VolumeSettings in that case
    if (volSet?.fadeSteps != null && volSet!.fadeSteps.isNotEmpty) {
      _fadeDuration =
          volSet.fadeSteps[volSet.fadeSteps.length - 1].time.inSeconds;
    }

    // _fadeDirection = alm?.volumeSettings.fadeDirection ?? 'up'; // TODO: this would be cool for staircase
    // fade step 2 volume is greater than fade step 1 volume -> up otherwise down

    if (alm != null) {
      logger.i('In editing mode for alarm: ${alm.name} / ${alm.id}');
      _editing = true;
    }

    _alarmId = alm?.id ?? -1;
    _enabled = alm?.enabled ?? true;
    titleController.text = alm?.name ?? 'My Alarm';
    notificationController.text = alm?.description ?? 'Alarm is ringing!';
    _vibrate = alm?.vibrate ?? true;

    _alarmTime = alm?.dateTime ?? DateTime.now();

    _assetAudioPath = alm?.assetAudioPath ?? "";

    _repeatDays = alm?.repeatDays ?? List.filled(7, false, growable: false);

    AssetManifest.loadFromAssetBundle(rootBundle).then((manifest) {
      logger.i('Loaded asset manifest: ${manifest.toString()}');
      final assetList = manifest.listAssets();
      logger.i('Asset list: $assetList');
      setState(() {
        _alarmAudioOptions =
            assetList
                .where(
                  (asset) =>
                      asset.startsWith('assets/alarms/') &&
                      asset.endsWith('.mp3'),
                )
                .toList();
        if (_alarmAudioOptions.isNotEmpty && _assetAudioPath.isEmpty) {
          _assetAudioPath = _alarmAudioOptions.first;
        }
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    notificationController.dispose();
    super.dispose();
  }

  String fmtAudioName(String asset) => asset
      .split('/')
      .last
      .split('.')
      .first
      .replaceAll('_', ' ')
      .splitMapJoin(
        RegExp('(^| )[a-zA-Z]'),
        onMatch: (m) => m.group(0)!.toUpperCase(),
        onNonMatch: (n) => n.toLowerCase(),
      );

  bool timePast(DateTime time) =>
      time.isBefore(DateTime.now()) && !_repeatDays.any((day) => day);

  TextFormField get titleFormField => TextFormField(
    decoration: InputDecoration(labelText: 'Alarm Title'),
    controller: titleController,
    textInputAction: TextInputAction.next,
    autofocus: true,
    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
  );

  TextFormField get notificationFormField => TextFormField(
    decoration: InputDecoration(labelText: 'Notification Text'),
    controller: notificationController,
    textInputAction: TextInputAction.done,
  );

  Future<void> pickTime() async {
    DateTime initial =
        timePast(_alarmTime)
            ? DateTime.now().add(Duration(minutes: 1))
            : _alarmTime;

    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: initial,
    );
    if (date == null || !mounted) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    var setTime = date.copyWith(
      hour: time.hour,
      minute: time.minute,
      second: 0,
      millisecond: 0,
    );

    if (timePast(setTime) && mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              content: Text(
                "Please select a time\nin the future!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }

    setState(() => _alarmTime = setTime);
  }

  TextFormField get timeFormField => TextFormField(
    decoration: InputDecoration(labelText: 'Alarm Time'),
    textInputAction: TextInputAction.done,
    readOnly: true,
    keyboardType: TextInputType.datetime,
    controller: TextEditingController(
      text:
          timePast(_alarmTime)
              ? 'Tap to set'
              : NamedAlarm.formatTime(_alarmTime),
    ),
    validator:
        (value) =>
            timePast(_alarmTime) ? 'Please select a time in the future' : null,
    onTap: pickTime,
  );

  DropdownButtonFormField get soundSelector => DropdownButtonFormField<String>(
    decoration: const InputDecoration(labelText: 'Sound'),
    value: _assetAudioPath,
    items:
        _alarmAudioOptions
            .map(
              (pth) =>
                  DropdownMenuItem(value: pth, child: Text(fmtAudioName(pth))),
            )
            .toList(),
    onChanged: (value) => setState(() => _assetAudioPath = value!),
  );

  AlarmEditorSwitchListTile get toggleVibrate => AlarmEditorSwitchListTile(
    title: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.vibration),
        ),
        Text('Vibrate'),
      ],
    ),
    value: _vibrate,
    onChanged: (value) => setState(() => _vibrate = value),
  );

  AlarmEditorSwitchListTile get systemVolumeToggle => AlarmEditorSwitchListTile(
    title: Text('Use System Volume'),
    value: _useSystemVolume,
    onChanged: (value) => setState(() => _useSystemVolume = value),
  );

  ListTile? get volumeTypeDropdown =>
      _useSystemVolume
          ? null
          : ListTile(
            title: Text('Volume Type'),
            trailing: DropdownButton<VolumeType>(
              value: _volumeType,
              items: [
                DropdownMenuItem(value: VolumeType.fixed, child: Text('Fixed')),
                DropdownMenuItem(value: VolumeType.fade, child: Text('Fade')),
                DropdownMenuItem(
                  value: VolumeType.staircaseFade,
                  child: Text('Staircase Fade'),
                ),
              ],
              onChanged:
                  (value) =>
                      setState(() => _volumeType = value ?? VolumeType.fixed),
            ),
          );

  // ListTile? get fadeDirectionDropdown =>
  //     _useSystemVolume
  //         ? null
  //         : ListTile(
  //           title: Text('Fade Direction'),
  //           trailing: DropdownButton<String>(
  //             value: _fadeDirection,
  //             items: [
  //               DropdownMenuItem(value: 'up', child: Text('Up')),
  //               DropdownMenuItem(value: 'down', child: Text('Down')),
  //             ],
  //             onChanged: (value) => setState(() => _fadeDirection = value!),
  //           ),
  //         );

  AlarmEditorSliderListTile? get volumeSlider =>
      _useSystemVolume
          ? null
          : AlarmEditorSliderListTile(
            title:
                '${_volumeType != VolumeType.fixed ? 'Max ' : ''}Volume - ${_volume.toInt()}%',
            slider: Slider(
              value: _volume,
              min: 0,
              max: 100,
              divisions: 100,
              label: "${_volume.toInt()}%",
              onChanged: (value) => setState(() => _volume = value),
            ),
          );

  AlarmEditorSliderListTile? get fadeDurationSlider =>
      _useSystemVolume || _volumeType == VolumeType.fixed
          ? null
          : AlarmEditorSliderListTile(
            title: 'Fade Length - $_fadeDuration seconds',
            slider: Slider(
              value: _fadeDuration.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '${_fadeDuration.toString()}s',
              onChanged:
                  (value) => setState(() => _fadeDuration = value.toInt()),
            ),
          );

  AlarmEditorSliderListTile? get staircaseFadeStepsSlider =>
      _useSystemVolume || _volumeType != VolumeType.staircaseFade
          ? null
          : AlarmEditorSliderListTile(
            title: 'Fade Steps - $_fadeStepsCount',
            slider: Slider(
              value: _fadeStepsCount.toDouble(),
              min: 2,
              max: 15,
              divisions: 13,
              label: _fadeStepsCount.toString(),
              onChanged:
                  (value) => setState(() => _fadeStepsCount = value.toInt()),
            ),
          );

  AlarmEditorExpansionTile get volumeSettingsTile => AlarmEditorExpansionTile(
    title: 'Volume Settings',
    expanded: _volumeSettingsExpanded,
    children:
        [
          systemVolumeToggle,
          volumeTypeDropdown,
          // fadeDirectionDropdown,
          volumeSlider,
          fadeDurationSlider,
          staircaseFadeStepsSlider,
        ].nonNulls.toList(),
    onExpansionChanged:
        (bool expanded) => setState(() => _volumeSettingsExpanded = expanded),
  );

  WeekdaySelector get repeatDaysTile => WeekdaySelector(
    // % 7 because if `day` is sunday, then it's 7, because of DateTime.sunday being 7
    onChanged:
        (int day) =>
            setState(() => _repeatDays[day % 7] = !_repeatDays[day % 7]),
    shortWeekdays: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
    firstDayOfWeek: DateTime.sunday,
    values: _repeatDays,
  );

  VolumeSettings get generateVolumeSettings {
    final volume = _useSystemVolume ? null : _volume / 100;
    switch (_volumeType) {
      case VolumeType.fixed:
        return VolumeSettings.fixed(volume: volume);
      case VolumeType.fade:
        return VolumeSettings.fade(
          fadeDuration: Duration(seconds: _fadeDuration),
          volume: volume,
        );
      case VolumeType.staircaseFade:
        return VolumeSettings.staircaseFade(
          fadeSteps: List.generate(
            _fadeStepsCount, // should never be less than 2; if it is, there's an issue elsewhere
            (index) => VolumeFadeStep(
              Duration(seconds: (_fadeDuration * index) ~/ _fadeStepsCount),
              (_volume / 100) * (index / (_fadeStepsCount - 1)),
            ),
          ),
          volume: volume,
        );
    }
  }

  void save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (await widget.alarmConnect.getAlarm(NamedAlarm.formatId(_alarmTime)) !=
            null &&
        _alarmId !=
            NamedAlarm.formatId(
              _alarmTime,
            ) && // make sure we aren't editing the same alarm
        mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              content: Text(
                "You can't have two alarms set for the same time!",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final notificationSettings = NotificationSettings(
      title: titleController.text,
      body: notificationController.text,
      stopButton: 'Stop',
      icon: 'notifications_active',
    );

    final alarm = NamedAlarm(
      // we don't need to worry about alarmId being different ->
      // we pass it to editAlarm in order to (potentially) delete the old alarm
      id: NamedAlarm.formatId(_alarmTime),
      name: titleController.text,
      description: notificationController.text,
      dateTime: _alarmTime,
      assetAudioPath: _assetAudioPath,
      volumeSettings: generateVolumeSettings,
      notificationSettings: notificationSettings,
      enabled: _enabled,
      repeatDays: _repeatDays,
      vibrate: _vibrate,
    );

    if (_editing) {
      await widget.alarmConnect.editAlarm(
        timestampId: _alarmId,
        newAlarm: alarm,
      );
    } else {
      await widget.alarmConnect.createAlarm(alarm);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      titleFormField,
      notificationFormField,
      timeFormField,
      repeatDaysTile,
      soundSelector,
      toggleVibrate,
      volumeSettingsTile,
    ];

    return Padding(
      padding: EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: save,
                label: Text('Save'),
                icon: Icon(Icons.alarm_on),
              ),
              ...fields.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: f,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmEditorSwitchListTile extends StatelessWidget {
  final Widget title;
  final bool value;
  final Function(bool) onChanged;

  const AlarmEditorSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: title,
      value: value,
      onChanged: onChanged,
      thumbIcon: WidgetStateProperty.fromMap({
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      }),
    );
  }
}

class AlarmEditorSliderListTile extends StatelessWidget {
  final String title;
  final Slider slider;

  const AlarmEditorSliderListTile({
    super.key,
    required this.title,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(slider.min.toInt().toString()),
              Expanded(child: slider),
              SizedBox(width: 25, child: Text(slider.max.toInt().toString())),
            ],
          ),
        ],
      ),
    );
  }
}

class AlarmEditorExpansionTile extends StatelessWidget {
  final bool _expanded;
  final String title;
  final List<Widget> children;
  final Function(bool) onExpansionChanged;

  const AlarmEditorExpansionTile({
    super.key,
    required bool expanded,
    required this.title,
    required this.children,
    required this.onExpansionChanged,
  }) : _expanded = expanded;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      trailing: Icon(
        _expanded ? Icons.arrow_drop_down_circle : Icons.arrow_left,
      ),
      tilePadding: EdgeInsets.zero,
      onExpansionChanged: onExpansionChanged,
      children: children,
    );
  }
}
