// views/graph_contract.dart

import 'package:agile_avengers_get_fit/models/exercise_data.dart';
import 'package:agile_avengers_get_fit/models/exercise_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

abstract class GraphViewContract {
  void updateChart(
    List<FlSpot> spots,
    List<String> labels,
    double minY,
    double maxY,
  );
  void updateStats(ExerciseStats stats);
}

abstract class GraphPresenterContract {
  void processData(List<ExerciseData> data);
  List<LineChartBarData> createMultiSeriesData(
    Map<String, List<ExerciseData>> groupedData,
    List<Color> colors,
  );
  Map<String, List<ExerciseData>> groupDataBy(
    List<ExerciseData> data,
    String groupBy,
  );
  ExerciseStats calculateStats(List<ExerciseData> data);
}
