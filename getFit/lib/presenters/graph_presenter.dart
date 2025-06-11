// presenters/graph_presenter.dart

import 'package:agile_avengers_get_fit/models/exercise_data.dart';
import 'package:agile_avengers_get_fit/models/exercise_stats.dart';
import 'package:agile_avengers_get_fit/views/graph_contract.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphPresenter implements GraphPresenterContract {
  final GraphViewContract _view;

  GraphPresenter(this._view);

  @override
  void processData(List<ExerciseData> data) {
    if (data.isEmpty) return;

    // Sort data for chart (important for time series)
    final sortedData = List<ExerciseData>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Convert filtered data into FlSpot list
    final List<FlSpot> spots = [];
    final List<String> xLabels = [];

    for (int i = 0; i < sortedData.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedData[i].value.toDouble()));

      // Get labels for X axis
      final bool hasSingleExercise = data.every(
        (item) => item.exercise == data[0].exercise,
      );

      xLabels.add(
        hasSingleExercise ? sortedData[i].variable : sortedData[i].exercise,
      );
    }

    // Calculate min and max Y values with padding
    final values = data.map((e) => e.value.toDouble()).toList();
    final double maxY = values.reduce((a, b) => a > b ? a : b);
    final double minY = values.reduce((a, b) => a < b ? a : b);
    final double padding = (maxY - minY) * 0.1; // 10% padding

    // Update view with chart data
    _view.updateChart(
      spots,
      xLabels,
      minY - padding > 0 ? minY - padding : 0,
      maxY + padding,
    );

    // Calculate and update stats
    final stats = calculateStats(data);
    _view.updateStats(stats);
  }

  @override
  Map<String, List<ExerciseData>> groupDataBy(
    List<ExerciseData> data,
    String groupBy,
  ) {
    final Map<String, List<ExerciseData>> groupedData = {};

    for (final item in data) {
      final String key = groupBy == 'exercise' ? item.exercise : item.variable;
      groupedData[key] = [...groupedData[key] ?? [], item];
    }

    // Sort each group by timestamp
    groupedData.forEach((key, items) {
      items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });

    return groupedData;
  }

  @override
  List<LineChartBarData> createMultiSeriesData(
    Map<String, List<ExerciseData>> groupedData,
    List<Color> colors,
  ) {
    final List<LineChartBarData> lineBars = [];
    int colorIndex = 0;

    groupedData.forEach((key, items) {
      final List<FlSpot> spots = [];

      for (int i = 0; i < items.length; i++) {
        spots.add(FlSpot(i.toDouble(), items[i].value.toDouble()));
      }

      final color = colors[colorIndex % colors.length];
      colorIndex++;

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: spots.length < 15),
          belowBarData: BarAreaData(show: false),
        ),
      );
    });

    return lineBars;
  }

  @override
  ExerciseStats calculateStats(List<ExerciseData> data) {
    final values = data.map((item) => item.value).toList();
    return ExerciseStats.fromValues(values);
  }
}
