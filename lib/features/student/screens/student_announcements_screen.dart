import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool _isLoading = false;
  late List<AnnouncementModel> _announcements;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // final announcementData = await adminRepository.getAnnouncementsForStudent(studentId);
    
    final auth = context.read<AuthProvider>();
    final student = auth.currentUser as StudentModel;
    
    _announcements = DummyData.announcements.where((a) {
      final courseMatch = a.targetCourses.contains(student.courseType);
      final branchMatch = a.targetBranches.contains(student.branch) || a.targetBranches.length >= 4;
      return courseMatch && branchMatch;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Notice Board", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),

      body: _announcements.isEmpty
          ? const EmptyState(
              icon: Icons.campaign_rounded,
              title: "No Announcements",
              subtitle: "All important notices will appear here.",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];

                final isHigh = announcement.priority.toLowerCase() == 'high';
                final color = isHigh ? AppColors.error : AppColors.warning;
                final bgColor = isHigh ? AppColors.errorSurface : AppColors.warningSurface;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
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
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              isHigh ? Icons.push_pin_rounded : Icons.announcement_rounded,
                              color: color,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        announcement.description,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            announcement.createdAt.toString().split(' ')[0],
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                          ),
                          if (announcement.isPinned) ...[
                            const Spacer(),
                            const Icon(Icons.push_pin, size: 14, color: AppColors.warning),
                            const SizedBox(width: AppSpacing.xs),
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
