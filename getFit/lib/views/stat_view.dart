import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:agile_avengers_get_fit/views/personal_records.dart';
import 'package:flutter/material.dart';

import 'database_view.dart';

class StatView extends StatelessWidget {
  const StatView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(context: context, title: 'Stats'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Stats"),
            SizedBox(
              height: 20,
            ), // Spacing between "Stats" text and the first button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonalRecords()),
                );
              },
              child: Text("Personal Records"),
            ),
            SizedBox(height: 20), // Spacing between the two buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DatabaseView()),
                );
              },
              child: Text("History"),
            ),
          ],
        ),
      ),
    );
  }
}
