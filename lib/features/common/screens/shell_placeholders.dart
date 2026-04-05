import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No placeholders needed anymore as Student, Professor, and Admin shells are implemented.
// Keeping this file empty or adding a generic ErrorShell if needed.

class GenericShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const GenericShell({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
    );
  }
}
