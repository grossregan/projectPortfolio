import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class PersonalRecords extends StatefulWidget {
  const PersonalRecords({super.key});

  @override
  State<PersonalRecords> createState() => _PersonalRecordsState();
}

class _PersonalRecordsState extends State<PersonalRecords> {
  List<Map<String, dynamic>> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecentPersonalBests();
  }

  Future<void> _loadRecentPersonalBests() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('exercises')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .get();

      final List<Map<String, dynamic>> loadedRecords = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('exercise') &&
            data.containsKey('value') &&
            data.containsKey('timestamp')) {
          loadedRecords.add({
            'exercise': data['exercise'],
            'value': data['value'],
            'timestamp': data['timestamp'],
          });
        }
      }

      setState(() {
        _recentRecords = loadedRecords;
      });
    } catch (e) {
      logger.e('Error loading recent personal bests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recent personal bests.')),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(context: context, title: "Personal Records"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _recentRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _recentRecords.length,
                  itemBuilder: (context, index) {
                    final record = _recentRecords[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          "${record['exercise']} - ${record['value']}",
                        ),
                        subtitle: Text(
                          "Achieved on: ${_formatTimestamp(record['timestamp'])}",
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
