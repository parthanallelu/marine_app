import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class ProfessorProfileScreen extends StatefulWidget {
  const ProfessorProfileScreen({super.key});

  @override
  State<ProfessorProfileScreen> createState() => _ProfessorProfileScreenState();
}

class _ProfessorProfileScreenState extends State<ProfessorProfileScreen> {
  bool _isLoading = true;
  late List<BatchModel> _myBatches;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final prof = authProvider.currentUser as ProfessorModel?;
    
    if (prof == null) {
      setState(() {
        _myBatches = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate slight delay for future-readiness
    _myBatches = DummyData.batches.where((b) => b.professorId == prof.id).toList();
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Role security check
    if (!authProvider.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final prof = authProvider.currentUser as ProfessorModel?;
    if (prof == null) {
       return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text("Error loading profile. Please login again.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyBlueDark, AppColors.navyBlueBase],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.gold.withAlpha((0.2 * 255).round()),
                        child: Text(
                          prof.name.isNotEmpty ? prof.name[0] : '?',
                          style: AppTextStyles.headingLarge.copyWith(color: AppColors.gold, fontSize: 36),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        prof.name,
                        style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        prof.qualification,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderChip(Icons.work_history_rounded, '${prof.experienceYears} Years Exp'),
                          SizedBox(width: AppSpacing.sm),
                          BranchBadge(branch: prof.branch),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Academic Summary Card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.cardRadius,
                    boxShadow: AppShadows.elevated,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _summaryItem("Batches", _myBatches.length.toString(), Icons.groups_rounded, AppColors.oceanBlue),
                        VerticalDivider(width: AppSpacing.xxl),
                        _summaryItem("Subjects", prof.subjects.length.toString(), Icons.book_rounded, AppColors.success),
                        VerticalDivider(width: AppSpacing.xxl),
                        _summaryItem("Specialty", "Expert", Icons.grade_rounded, AppColors.gold),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contact & Professional Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: DashboardCard(
                title: "Professional Information",
                child: Column(
                  children: [
                    InfoRow(icon: Icons.email_outlined, label: "Email", value: prof.email),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.phone_outlined, label: "Phone", value: prof.phone),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.psychology_outlined, label: "Specialization", value: prof.specialization),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.calendar_month_outlined, label: "Faculty Since", value: prof.createdAt.year.toString()),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xl).toSliver,

          // Subjects Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _buildSubjects(prof),
            ),
          ),

          SizedBox(height: AppSpacing.xl).toSliver,

          // My Batches Section
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: Text("My Assigned Batches", style: AppTextStyles.headingSmall),
            ),
          ),
          SizedBox(height: AppSpacing.md).toSliver,
          
          if (_myBatches.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: EmptyState(
                  icon: Icons.class_outlined,
                  title: "No Batches",
                  subtitle: "You don't have any assigned batches.",
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final batch = _myBatches[index];
                    return DashboardCard(
                      title: batch.name,
                      subtitle: batch.courseType,
                      leading: const Icon(Icons.group_rounded, color: AppColors.navyBlueBase),
                      trailing: Text('${batch.studentIds.length} Studs', style: AppTextStyles.caption),
                      child: const SizedBox.shrink(),
                      onTap: () {},
                    );
                  },
                  childCount: _myBatches.length,
                ),
              ),
            ),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 60),
              child: CustomButton(
                label: "Logout",
                isOutlined: true,
                color: AppColors.error,
                icon: Icons.logout_rounded,
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjects(ProfessorModel prof) {
    return DashboardCard(
      title: "Teaching Subjects",
      icon: Icons.book_rounded,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: prof.subjects.map((subject) => Chip(
          label: Text(subject, style: AppTextStyles.labelSmall),
          backgroundColor: AppColors.navyBlueSurface,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        )).toList(),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.15 * 255).round()),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: AppSpacing.xxs),
        Text(value, style: AppTextStyles.headingSmall.copyWith(color: color, fontSize: 18)),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: AppTextStyles.labelLarge)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: Text("LOGOUT", style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

extension on Widget {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}
