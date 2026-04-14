import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    try {
      // 800ms delay for splash
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;

      if (!isLoggedIn) {
        context.go(AppRoutes.roleSelection);
      } else {
        if (authProvider.isStudent) {
          context.go(AppRoutes.studentHome);
        } else if (authProvider.isProfessor) {
          context.go(AppRoutes.professorHome);
        } else if (authProvider.isAdmin) {
          context.go(AppRoutes.adminHome);
        } else {
          context.go(AppRoutes.roleSelection);
        }
      }
    } catch (e) {
      debugPrint("Splash redirect error: $e");
      if (mounted) {
        context.go(AppRoutes.roleSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardTheme.color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.subtle,
              ),
              child: Image.asset(
                AppConstants.logo,
                width: 140,
                height: 140,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyBlueBase),
              strokeWidth: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppConstants.appName.toUpperCase(),
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.navyBlueBase,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
