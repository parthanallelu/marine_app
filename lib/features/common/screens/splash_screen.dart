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
    // 800ms delay for splash
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    final navigator = GoRouter.of(context);
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    
    if (!isLoggedIn) {
      navigator.go(AppRoutes.roleSelection);
    } else {
      if (authProvider.isStudent) {
        navigator.go(AppRoutes.studentHome);
      } else if (authProvider.isProfessor) {
        navigator.go(AppRoutes.professorHome);
      } else if (authProvider.isAdmin) {
        navigator.go(AppRoutes.adminHome);
      } else {
        navigator.go(AppRoutes.roleSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlueBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha((0.1 * 255).round()), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: ClipOval(child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover)),
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white, letterSpacing: 1.2),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold)),
          ],
        ),
      ),
    );
  }
}
