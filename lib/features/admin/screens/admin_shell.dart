import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({
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
        indicatorColor: AppColors.navyBlueSurface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.navyBlueBase),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.school_rounded, color: AppColors.navyBlueBase),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.navyBlueBase),
            label: 'Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.payments_rounded, color: AppColors.navyBlueBase),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined, color: AppColors.textHint),
            selectedIcon: const Icon(Icons.campaign_rounded, color: AppColors.navyBlueBase),
            label: 'Notices',
          ),
        ],
      ),
    );
  }
}
