import 'package:agile_avengers_get_fit/presenters/alarms_presenter.dart';
import 'package:agile_avengers_get_fit/views/alarms_list.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AlarmsPage extends StatefulWidget {
  final AlarmsPresenter alarmConnect;

  const AlarmsPage({super.key, required this.alarmConnect});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  ScrollPosition? _scrollPos;
  Widget _fabContent = const Icon(Icons.alarm_add);

  @override
  void initState() {
    super.initState();
    widget.alarmConnect.setStateFn(setState);
    if (widget.alarmConnect.alarms.isEmpty ||
        widget.alarmConnect.alarms.any((alarm) => alarm.isInPast)) {
      loadAlarms();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.alarmConnect.setStateFn((fn) => fn());
  }
  // @override
  // void dispose() {
  //   widget.alarmConnect.dispose();
  //   super.dispose();
  // }

  Future<void> loadAlarms() async {
    logger.i('Loading alarms');
    // this is jank but setState can't be async, and there's no point making this fn async so .then it is
    await widget.alarmConnect.loadAlarms().then((_) => setState(() {}));
  }

  FloatingActionButton getFab() {
    if (_scrollPos == null ||
        _scrollPos!.userScrollDirection == ScrollDirection.forward ||
        _scrollPos!.pixels < 1) {
      _fabContent = Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(Icons.alarm_add),
          ),
          Text('Create Alarm'),
        ],
      );
    }

    if (_scrollPos != null &&
        _scrollPos!.userScrollDirection == ScrollDirection.reverse) {
      _fabContent = Icon(Icons.alarm_add);
    }
    return FloatingActionButton.extended(
      onPressed:
          () => widget.alarmConnect
              .visitAlarmEditor(context)
              .then((_) => loadAlarms()),
      label: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder:
            (Widget child, Animation<double> animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            ),
        child: GestureDetector(
          onLongPress: () async {
            logger.i(await Alarm.getAlarms());
          },
          child: _fabContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body =
    // widget.alarmConnect.alarms == null
    //     ? const Center(child: CircularProgressIndicator())
    //     :
    AlarmsList(
      alarms: widget.alarmConnect.alarms,
      onChange: loadAlarms,
      onScroll: (pos) => setState(() => _scrollPos = pos),
      alarmConnect: widget.alarmConnect,
    );

    return CommonScaffold(
      appBar: CommonAppBar(context: context, title: 'Alarms'),
      body: Padding(padding: const EdgeInsets.all(8.0), child: body),
      floatingActionButton: getFab(),
    );
  }
}
