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
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppColors.navyBlueBase.withAlpha((0.1 * 255).round()),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.home_rounded, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.assignment_rounded, color: Colors.white),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.folder_rounded, color: Colors.white),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.forum_rounded, color: Colors.white),
            label: 'Interview',
          ),
        ],
      ),
    );
  }
}
