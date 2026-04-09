import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color _getRoleColor(String? role) {
    if (role == AppConstants.roleStudent) return AppColors.navyBlueBase;
    if (role == AppConstants.roleProfessor) return AppColors.oceanBlue;
    if (role == AppConstants.roleAdmin) return AppColors.gold;
    return AppColors.navyBlueBase;
  }

  IconData _getRoleIcon(String? role) {
    if (role == AppConstants.roleStudent) return Icons.school_rounded;
    if (role == AppConstants.roleProfessor) return Icons.person_search_rounded;
    if (role == AppConstants.roleAdmin) return Icons.admin_panel_settings_rounded;
    return Icons.school_rounded;
  }

  String _getRoleLabel(String? role) {
    if (role == AppConstants.roleStudent) return 'Student';
    if (role == AppConstants.roleProfessor) return 'Professor';
    if (role == AppConstants.roleAdmin) return 'Administrator';
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roleColor = _getRoleColor(auth.selectedRole);
    final roleIcon = _getRoleIcon(auth.selectedRole);
    final roleLabel = _getRoleLabel(auth.selectedRole);

    return AppPageShell(
      title: "$roleLabel Login",
      subtitle: AppConstants.appName,
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Info Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.oceanBlueSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.oceanBlue.withAlpha((0.3 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.oceanBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Demos: student@gmail.com, teacher@gmail.com, admin@gmail.com (PW: 123456)",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.oceanBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text("Email or Phone", style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: "Enter your email or phone",
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter email' : null,
              ),

              const SizedBox(height: AppSpacing.lg),
              Text("Password", style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outlined),
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),

              const SizedBox(height: AppSpacing.xl),
              if (auth.errorMessage != null) ...[
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              CustomButton(
                label: "Login",
                width: double.infinity,
                isLoading: auth.isLoading,
                icon: Icons.login_rounded,
                color: roleColor,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await auth.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                label: "Back to Role Selection",
                width: double.infinity,
                isOutlined: true,
                color: roleColor,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
