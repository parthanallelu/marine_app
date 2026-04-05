import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  String _selectedBranch = "All";

  @override
  Widget build(BuildContext context) {
    final announcements = DummyData.announcements.where((a) {
      if (_selectedBranch == "All") return true;
      return a.targetBranches.contains(_selectedBranch);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Announcements", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // BRANCH FILTER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _BranchChip(
                    label: "Global",
                    isSelected: _selectedBranch == "All",
                    onTap: () => setState(() => _selectedBranch = "All"),
                  ),
                  ...AppConstants.branches.map((branch) => _BranchChip(
                        label: branch,
                        isSelected: _selectedBranch == branch,
                        onTap: () => setState(() => _selectedBranch = branch),
                      )),
                ],
              ),
            ),
          ),

          // ANNOUNCEMENT LIST
          Expanded(
            child: announcements.isEmpty
                ? const EmptyState(
                    icon: Icons.campaign_rounded,
                    title: "No Announcements",
                    subtitle: "There are no notices for the selected filter.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _AdminAnnouncementCard(announcement: announcement);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAnnouncementDialog(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("New Update", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Broadcast Update", style: AppTextStyles.headingMedium),
              const SizedBox(height: 20),
              const CustomTextField(label: "Title", hintText: "e.g. Special Guest Lecture"),
              const SizedBox(height: 16),
              const CustomTextField(
                label: "Message",
                hintText: "Enter the announcement details...",
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text("Target Branch", style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              // Dummy Multi-select representation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: AppRadius.inputRadius,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Text("Academy Wide", style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "CANCEL",
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: "BROADCAST",
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Announcement broadcasted successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BranchChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminAnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AdminAnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PriorityTag(priority: announcement.priority),
              const Spacer(),
              if (announcement.isPinned)
                const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 12),
          Text(announcement.title, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(
            announcement.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                "By ${announcement.authorName}",
                style: AppTextStyles.caption.copyWith(color: AppColors.navyBlueBase),
              ),
              const Spacer(),
              Text(
                announcement.createdAt.toString().split(' ')[0],
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
