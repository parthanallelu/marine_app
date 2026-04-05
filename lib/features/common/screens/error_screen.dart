import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';

class ErrorScreen extends StatelessWidget {
  final GoRouterState state;

  const ErrorScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find the page you're looking for.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: "Go Home",
              onPressed: () => context.go(AppRoutes.roleSelection),
            ),
          ],
        ),
      ),
    );
  }
}
