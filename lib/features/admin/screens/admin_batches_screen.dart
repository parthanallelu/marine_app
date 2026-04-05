import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminBatchesScreen extends StatelessWidget {
  const AdminBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Batch Management", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.branches.length,
        itemBuilder: (context, index) {
          final branch = AppConstants.branches[index];
          final batchesInBranch = DummyData.batches.where((b) => b.branch == branch).toList();
          
          if (batchesInBranch.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.navyBlueBase, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "$branch Branch",
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.navyBlueBase),
                    ),
                    const Spacer(),
                    Text(
                      "${batchesInBranch.length} Active",
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ...batchesInBranch.map((batch) => _AdminBatchCard(batch: batch)),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.navyBlueBase,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _AdminBatchCard extends StatelessWidget {
  final BatchModel batch;
  const _AdminBatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name, style: AppTextStyles.labelLarge),
                    Text(batch.courseType, style: AppTextStyles.caption),
                  ],
                ),
              ),
              CourseBadge(courseType: batch.courseType),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _BatchMeta(icon: Icons.person_rounded, label: batch.professorName),
              const Spacer(),
              _BatchMeta(icon: Icons.schedule_rounded, label: batch.timing),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BatchMeta(icon: Icons.people_outline_rounded, label: "${batch.studentIds.length} Students"),
              const Spacer(),
              Text(
                "Started ${batch.startDate.toString().split(' ')[0]}",
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatchMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BatchMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
