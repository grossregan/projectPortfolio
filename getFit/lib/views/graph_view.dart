// views/graph_view.dart
import 'package:agile_avengers_get_fit/models/exercise_data.dart';
import 'package:agile_avengers_get_fit/models/exercise_stats.dart';
import 'package:agile_avengers_get_fit/presenters/graph_presenter.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'graph_contract.dart';

class GraphView extends StatefulWidget {
  final List<ExerciseData> data;
  final String title;
  const GraphView({super.key, required this.data, this.title = 'Graph View'});

  @override
  State createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> implements GraphViewContract {
  late GraphPresenter _presenter;
  List _spots = [];
  List _xLabels = [];
  double _minY = 0;
  double _maxY = 0;
  late ExerciseStats _stats;

  @override
  void initState() {
    super.initState();
    _presenter = GraphPresenter(this);
    _stats = ExerciseStats(min: 0, max: 0, average: 0, count: 0);

    // Process data to prepare chart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presenter.processData(widget.data);
    });
  }

  @override
  void updateChart(List spots, List labels, double minY, double maxY) {
    setState(() {
      _spots = spots;
      _xLabels = labels;
      _minY = minY;
      _maxY = maxY;
    });
  }

  @override
  void updateStats(ExerciseStats stats) {
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group by exercise and variable if needed
    final bool hasSingleExercise = widget.data.every(
      (item) => item.exercise == widget.data[0].exercise,
    );
    final bool hasSingleVariable = widget.data.every(
      (item) => item.variable == widget.data[0].variable,
    );
    // For multiple exercises or variables, we might need a different visualization
    if (!hasSingleVariable && !hasSingleExercise) {
      return _buildMultiSeriesChart(context);
    }
    return CommonScaffold(
      appBar: CommonAppBar(
        context: context,
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Data Info',
            onPressed: () => _showDataInfo(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _spots.isNotEmpty
                      ? _buildLineChart()
                      : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 16),
            _buildStatsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _xLabels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _xLabels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (_spots.length - 1).toDouble(),
        minY: _minY * 0.9,
        maxY: _maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: _spots.map((spot) => FlSpot(spot.x, spot.y)).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                  begin: Theme.of(context).primaryColor,
                  end: Theme.of(context).primaryColorLight,
                ).lerp(0.2)!,
                ColorTween(
                  begin: Theme.of(context).primaryColor,
                  end: Theme.of(context).primaryColorLight,
                ).lerp(0.8)!,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true, getDotPainter: _dotPainter),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  ColorTween(
                    begin: Theme.of(context).primaryColor,
                    end: Colors.transparent,
                  ).lerp(0.2)!.withValues(alpha: 0.3),
                  ColorTween(
                    begin: Theme.of(context).primaryColor,
                    end: Colors.transparent,
                  ).lerp(0.8)!.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (_maxY - _minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xffe7e8ec), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: const Color(0xffe7e8ec), strokeWidth: 1);
          },
        ),
      ),
    );
  }

  static FlDotPainter _dotPainter(
    FlSpot spot,
    double xPercentage,
    LineChartBarData bar,
    int index,
  ) {
    return FlDotCirclePainter(
      radius: 4,
      color: bar.gradient?.colors.first ?? Colors.blue,
      strokeWidth: 2,
      strokeColor: Colors.white,
    );
  }

  Widget _buildStatsSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Min', _stats.min.toStringAsFixed(1)),
            _buildStatItem('Max', _stats.max.toStringAsFixed(1)),
            _buildStatItem('Avg', _stats.average.toStringAsFixed(1)),
            _buildStatItem('Count', _stats.count.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSeriesChart(BuildContext context) {
    // Implement multi-series chart for different exercises or variables
    return CommonScaffold(
      appBar: CommonAppBar(context: context, title: widget.title),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multiple exercises or variables detected',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildGroupedBarChart()),
            const SizedBox(height: 16),
            _buildStatsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedBarChart() {
    // Implement grouped bar chart for comparison
    // This is a simple placeholder - you would need to implement this based on your requirements
    return Center(
      child: Text(
        'Grouped data visualization not implemented yet',
        style: TextStyle(color: Theme.of(context).disabledColor),
      ),
    );
  }

  void _showDataInfo(BuildContext context) {
    // Show a dialog with information about the data
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Data Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise: ${widget.data.isNotEmpty ? widget.data[0].exercise : "N/A"}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Variable: ${widget.data.isNotEmpty ? widget.data[0].variable : "N/A"}',
                ),
                const SizedBox(height: 8),
                Text('Data points: ${widget.data.length}'),
                const SizedBox(height: 8),
                Text('Statistics:'),
                const SizedBox(height: 4),
                Text('  • Min: ${_stats.min.toStringAsFixed(1)}'),
                Text('  • Max: ${_stats.max.toStringAsFixed(1)}'),
                Text('  • Average: ${_stats.average.toStringAsFixed(1)}'),
                Text('  • Count: ${_stats.count}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
