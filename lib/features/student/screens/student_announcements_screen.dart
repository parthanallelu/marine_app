import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentUser as StudentModel;
    
    final announcements = DummyData.announcements.where((a) {
      final courseMatch = a.targetCourses.contains(student.courseType);
      final branchMatch = a.targetBranches.contains(student.branch) || a.targetBranches.length >= 4;
      return courseMatch && branchMatch;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Notice Board", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: announcements.isEmpty
          ? const EmptyState(
              icon: Icons.campaign_rounded,
              title: "No Announcements",
              subtitle: "All important notices will appear here.",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                final isHigh = announcement.priority.toLowerCase() == 'high';
                final color = isHigh ? AppColors.error : AppColors.warning;
                final bgColor = isHigh ? AppColors.errorSurface : AppColors.warningSurface;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.cardRadius,
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isHigh ? Icons.push_pin_rounded : Icons.announcement_rounded,
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(announcement.title, style: AppTextStyles.labelLarge),
                                Text(
                                  announcement.authorName,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                          PriorityTag(priority: announcement.priority),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        announcement.description,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            announcement.createdAt.toString().split(' ')[0],
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                          ),
                          if (announcement.isPinned) ...[
                            const Spacer(),
                            const Icon(Icons.push_pin, size: 14, color: AppColors.warning),
                            const SizedBox(width: 4),
                            const Text("Pinned", style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
