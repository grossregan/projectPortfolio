// views/database_view.dart

import 'package:agile_avengers_get_fit/models/exercise_data.dart';
import 'package:agile_avengers_get_fit/presenters/database_presenter.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:flutter/material.dart';

import 'database_contract.dart';
import 'graph_view.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView>
    implements DatabaseViewContract {
  late DatabasePresenter _presenter;

  String? _selectedExercise;
  String? _selectedVariable;
  List<ExerciseData> _filteredData = [];
  List<String> _exercises = [];
  List<String> _variables = [];
  bool _ascending = true;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = DatabasePresenter(this);
    _loadData();
  }

  void _loadData() {
    _presenter.loadData();
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _showErrorSnackBar(message);
  }

  @override
  void updateData(
    List<ExerciseData> filteredData,
    List<String> exercises,
    List<String> variables,
  ) {
    setState(() {
      _filteredData = filteredData;
      _exercises = exercises;
      _variables = variables;
    });
  }

  @override
  void refreshView() {
    setState(() {});
  }

  void _applyFilters() {
    _presenter.filterData(_selectedExercise, _selectedVariable, _ascending);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _loadData,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future<bool?> _showFilterDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Options'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Exercise'),
                      value: _selectedExercise,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Exercises'),
                        ),
                        ..._exercises.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }),
                      ],
                      onChanged: (newValue) {
                        setDialogState(() {
                          _selectedExercise = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Variable'),
                      value: _selectedVariable,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Variables'),
                        ),
                        ..._variables.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }),
                      ],
                      onChanged: (newValue) {
                        setDialogState(() {
                          _selectedVariable = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Clear All'),
                  onPressed: () {
                    setDialogState(() {
                      _selectedExercise = null;
                      _selectedVariable = null;
                    });
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        context: context,
        title: "Exercise Database",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildSortControls(),
          const SizedBox(height: 20),
          Expanded(child: _buildDataList()),
        ],
      ),
    );
  }

  Widget _buildFilterInfo() {
    final List<Widget> chips = [];

    if (_selectedExercise != null) {
      chips.add(
        Chip(
          label: Text('Exercise: $_selectedExercise'),
          onDeleted: () {
            setState(() {
              _selectedExercise = null;
              _applyFilters();
            });
          },
        ),
      );
    }

    if (_selectedVariable != null) {
      chips.add(
        Chip(
          label: Text('Variable: $_selectedVariable'),
          onDeleted: () {
            setState(() {
              _selectedVariable = null;
              _applyFilters();
            });
          },
        ),
      );
    }

    return chips.isEmpty
        ? const Text('No filters applied')
        : Wrap(spacing: 8, children: chips);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await _showFilterDialog(context);
              if (result == true) {
                _applyFilters();
              }
            },
            icon: const Icon(Icons.filter_list),
            label: const Text("Filter Data"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _filteredData.isEmpty
                    ? null
                    : () {
                      if (_filteredData.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => GraphView(
                                  data: _filteredData,
                                  title: _presenter.getGraphTitle(
                                    _selectedExercise,
                                    _selectedVariable,
                                  ),
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No data matches the selected filter.",
                            ),
                          ),
                        );
                      }
                    },
            icon: const Icon(Icons.bar_chart),
            label: const Text("View Graph"),
          ),
        ),
      ],
    );
  }

  Widget _buildSortControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.sort),
                const SizedBox(width: 8),
                const Text("Sort Order"),
              ],
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _ascending,
                  onChanged: (value) {
                    setState(() {
                      _ascending = value!;
                      _applyFilters();
                    });
                  },
                ),
                const Text("Min to Max"),
                Radio<bool>(
                  value: false,
                  groupValue: _ascending,
                  onChanged: (value) {
                    setState(() {
                      _ascending = value!;
                      _applyFilters();
                    });
                  },
                ),
                const Text("Max to Min"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    if (_filteredData.isEmpty) {
      return const Center(
        child: Text(
          "No data available based on current filters.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        final item = _filteredData[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              item.exercise,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.variable),
            trailing: Text(
              '${item.value}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
}
