import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    // Check if the user is an AdminModel before casting
    final adminName = user?.name ?? "Admin";
    
    // Global Stats
    final totalStudents = DummyData.students.length;
    final totalBatches = DummyData.batches.length;
    
    // Revenue Calculation (Mock)
    final totalFeesCollected = DummyData.feeRecords.fold<double>(0, (sum, f) => sum + f.paidAmount);
    final totalFeesPending = DummyData.feeRecords.fold<double>(0, (sum, f) => sum + (f.totalFees - f.paidAmount));
    final collectionPercentage = (totalFeesCollected + totalFeesPending) > 0 
        ? totalFeesCollected / (totalFeesCollected + totalFeesPending)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // SLIVER 1 — Global Admin Header
          SliverToBoxAdapter(
            child: _AdminHeader(adminName: adminName),
          ),

          // SLIVER 2 — Master KPIs
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: "Academy Students",
                      value: totalStudents.toString(),
                      icon: Icons.people_alt_rounded,
                      color: AppColors.navyBlueBase,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: "Total Batches",
                      value: totalBatches.toString(),
                      icon: Icons.layers_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 3 — Financial Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: DashboardCard(
                title: "Academy Fee Collection",
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.success,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 8.0,
                          percent: collectionPercentage,
                          center: Text(
                            "${(collectionPercentage * 100).toInt()}%",
                            style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          progressColor: AppColors.success,
                          backgroundColor: AppColors.success.withAlpha((0.15 * 255).round()),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FeeDetailItem(
                                label: "Collected",
                                value: "₹${totalFeesCollected.toInt()}",
                                color: AppColors.success,
                              ),
                              const SizedBox(height: 8),
                              _FeeDetailItem(
                                label: "Outstanding",
                                value: "₹${totalFeesPending.toInt()}",
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SLIVER 4 — Branch Quick-View
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: "Branch Oversight"),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.branches.length,
                      itemBuilder: (context, index) {
                        final branchName = AppConstants.branches[index];
                        final branchStudents = DummyData.students.where((s) => s.branch == branchName).length;
                        return _BranchCard(name: branchName, studentCount: branchStudents);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SLIVER 5 — Faculty Quick-View
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: DashboardCard(
                title: "Academic Faculty",
                icon: Icons.school_rounded,
                iconColor: AppColors.oceanBlue,
                actionLabel: "View All",
                onAction: () {},
                child: Column(
                  children: DummyData.professors.take(3).map((prof) => _FacultyTile(professor: prof)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String adminName;
  const _AdminHeader({required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Commanding Officer,",
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      Text(
                        adminName,
                        style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.read<AuthProvider>().logout(),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.gold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Super Academy Admin",
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FeeDetailItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: AppTextStyles.labelLarge.copyWith(color: color)),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  final String name;
  final int studentCount;

  const _BranchCard({required this.name, required this.studentCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.navyBlueBase, size: 20),
          ),
          const Spacer(),
          Text(name, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(
            "$studentCount Students",
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FacultyTile extends StatelessWidget {
  final ProfessorModel professor;
  const _FacultyTile({required this.professor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.oceanBlueSurface,
            child: Text(professor.name[0], style: const TextStyle(color: AppColors.oceanBlue)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(professor.name, style: AppTextStyles.labelLarge),
                Text(
                  "${professor.qualification} • ${professor.branch}",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
        ],
      ),
    );
  }
}
