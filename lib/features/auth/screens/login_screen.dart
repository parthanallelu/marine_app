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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // HEADER
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navyBlueDark, roleColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(roleIcon, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$roleLabel Login",
                              style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                            ),
                            Text(
                              AppConstants.appName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // BODY
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.oceanBlueSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.oceanBlue.withAlpha((0.3 * 255).round())),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.oceanBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Demo: Use any email & password 123456",
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.oceanBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text("Email or Phone", style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: "Enter your email or phone",
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter email' : null,
                    ),

                    const SizedBox(height: 16),
                    Text("Password", style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
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

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Feature coming soon!")),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (auth.errorMessage != null) ...[
                      Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                    ],

                    CustomButton(
                      label: "Login",
                      width: double.infinity,
                      isLoading: auth.isLoading,
                      icon: Icons.login_rounded,
                      color: roleColor,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await auth.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (!success && mounted) {
                            // Error is handled by provider and shown above
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    CustomButton(
                      label: "Back to Role Selection",
                      width: double.infinity,
                      isOutlined: true,
                      color: roleColor,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
