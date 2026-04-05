import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class ProfessorProfileScreen extends StatelessWidget {
  const ProfessorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final professor = context.watch<AuthProvider>().currentUser as ProfessorModel;
    final professorBatches = DummyData.batches.where((b) => b.professorId == professor.id).toList();
    final totalStudents = professorBatches.fold<int>(0, (sum, b) => sum + b.studentIds.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Profile Header
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.gold.withAlpha((0.25 * 255).round()),
                        child: Text(
                          professor.name[0],
                          style: AppTextStyles.headingLarge.copyWith(color: AppColors.gold, fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        professor.name,
                        style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        professor.qualification,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: professor.subjects.map((sub) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            sub,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SLIVER 2 — Professional Stats Card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.cardRadius,
                    boxShadow: AppShadows.elevated,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfessorStat(
                          label: "Students",
                          value: totalStudents.toString(),
                          icon: Icons.people_outline,
                          color: AppColors.oceanBlue,
                        ),
                        const VerticalDivider(width: 32),
                        _ProfessorStat(
                          label: "Experience",
                          value: "${professor.experienceYears}y",
                          icon: Icons.history_edu_rounded,
                          color: AppColors.gold,
                        ),
                        const VerticalDivider(width: 32),
                        _ProfessorStat(
                          label: "Batches",
                          value: professorBatches.length.toString(),
                          icon: Icons.groups_outlined,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SLIVER 3 — Professional Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: DashboardCard(
                title: "Professional Information",
                child: Column(
                  children: [
                    InfoRow(icon: Icons.work_outline, label: "Specialization", value: professor.specialization),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.email_outlined, label: "Official Email", value: professor.email),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.phone_outlined, label: "Phone", value: professor.phone),
                    const Divider(height: 1),
                    InfoRow(icon: Icons.history_outlined, label: "Joined Academy", value: professor.createdAt.toString().split(' ')[0]),
                  ],
                ),
              ),
            ),
          ),

          // SLIVER 4 — Assigned Batches Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DashboardCard(
                title: "Assigned Batches Dashboard",
                child: Column(
                  children: professorBatches.map((batch) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.class_rounded, color: AppColors.navyBlueBase, size: 20),
                    ),
                    title: Text(batch.name, style: AppTextStyles.labelLarge),
                    subtitle: Text("${batch.timing} • ${batch.studentIds.length} students", style: AppTextStyles.caption),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  )).toList(),
                ),
              ),
            ),
          ),

          // SLIVER 5 — Logout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                label: "Log out",
                isOutlined: true,
                color: AppColors.error,
                icon: Icons.logout_rounded,
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ProfessorStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfessorStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
