import 'package:flutter/material.dart';

class CommonAppBar extends AppBar {
  final BuildContext context;

  CommonAppBar({
    super.key,
    required this.context,
    required String title,
    super.actions,
    Color? backgroundColor,
  }) : super(
         title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
         backgroundColor:
             backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
       );
}
