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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.navyBlueBase.withAlpha((0.08 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.navyBlueBase),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded, color: AppColors.navyBlueBase),
                label: 'Students',
              ),
              NavigationDestination(
                icon: Icon(Icons.class_outlined),
                selectedIcon: Icon(Icons.class_rounded, color: AppConstants.roleAdmin == 'admin' ? AppColors.navyBlueBase : AppColors.navyBlueBase),
                label: 'Batches',
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments_rounded, color: AppColors.navyBlueBase),
                label: 'Fees',
              ),
              NavigationDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign_rounded, color: AppColors.navyBlueBase),
                label: 'Notices',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
