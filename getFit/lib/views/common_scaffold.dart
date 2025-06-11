import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final AppBar appBar;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;
  const CommonScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fitness-backround.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(),
          ),
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
