import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class StudentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        indicatorColor: Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).round()),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        selectedLabelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        unselectedLabelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Theme.of(context).hintColor),
            selectedIcon: Icon(Icons.home_rounded, color: Theme.of(context).colorScheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: Theme.of(context).hintColor),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: Theme.of(context).colorScheme.primary),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: Theme.of(context).hintColor),
            selectedIcon: Icon(Icons.assignment_rounded, color: Theme.of(context).colorScheme.primary),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined, color: Theme.of(context).hintColor),
            selectedIcon: Icon(Icons.folder_rounded, color: Theme.of(context).colorScheme.primary),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined, color: Theme.of(context).hintColor),
            selectedIcon: Icon(Icons.forum_rounded, color: Theme.of(context).colorScheme.primary),
            label: 'Interview',
          ),
        ],
      ),
    );
  }
}
