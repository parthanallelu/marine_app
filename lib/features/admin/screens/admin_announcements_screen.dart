import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
  late List<AnnouncementModel> _allAnnouncements;
  String _selectedBranch = "All";

  @override
  void initState() {
    super.initState();
    _allAnnouncements = List.from(DummyData.announcements);
  }

  @override
  Widget build(BuildContext context) {
    final announcements = _allAnnouncements.where((a) {
      if (_selectedBranch == "All") return true;
      return a.targetBranches.contains(_selectedBranch);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Notice Board", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // BRANCH FILTER
          Container(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _BranchChip(
                    label: "Academy Wide",
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
                    icon: Icons.campaign_outlined,
                    title: "No Announcements",
                    subtitle: "Create a notice to broadcast to the academy.",
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 80),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _AdminAnnouncementCard(
                        announcement: announcement,
                        onDelete: () => _confirmDeleteAnnouncement(announcement),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAnnouncementSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.campaign_rounded, color: Colors.white),
        label: Text("Post Notice", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateAnnouncementSheet() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = "Medium";
    bool isPinned = false;
    List<String> selectedBranches = ["All"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Broadcast New Notice", style: AppTextStyles.headingMedium),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          "This message will be visible to selected students and staff.",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        CustomTextField(
                          label: "Title",
                          hintText: "Enter a concise heading",
                          controller: titleController,
                          prefixIcon: Icons.title_rounded,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          label: "Description",
                          hintText: "Detail your announcement here...",
                          controller: descController,
                          maxLines: 4,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedPriority,
                                decoration: const InputDecoration(labelText: "Priority", prefixIcon: Icon(Icons.priority_high_rounded, size: 20)),
                                items: ["Low", "Medium", "High"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                onChanged: (val) => setModalState(() => selectedPriority = val!),
                              ),
                            ),
                            SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: SwitchListTile(
                                title: const Text("Pinned", style: TextStyle(fontSize: 14)),
                                value: isPinned,
                                onChanged: (val) => setModalState(() => isPinned = val),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text("Target Branches", style: AppTextStyles.labelLarge),
                        SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          children: ["All", ...AppConstants.branches].map((branch) {
                            final isSel = selectedBranches.contains(branch);
                            return FilterChip(
                              label: Text(branch, style: AppTextStyles.caption.copyWith(fontSize: 12, color: isSel ? Colors.white : AppColors.textPrimary)),
                              selected: isSel,
                              selectedColor: AppColors.navyBlueBase,
                              onSelected: (sel) {
                                setModalState(() {
                                  if (branch == "All") {
                                    selectedBranches = ["All"];
                                  } else {
                                    selectedBranches.remove("All");
                                    if (sel) {
                                      selectedBranches.add(branch);
                                    } else {
                                      selectedBranches.remove(branch);
                                      if (selectedBranches.isEmpty) selectedBranches = ["All"];
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: AppSpacing.xxxl),
                        CustomButton(
                          label: "PUBLISH BROADCAST",
                          width: double.infinity,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newNotice = AnnouncementModel(
                                id: const Uuid().v4(),
                                title: titleController.text,
                                description: descController.text,
                                createdAt: DateTime.now(),
                                authorName: "Principal Admin",
                                targetBranches: selectedBranches,
                                targetCourses: const ["All"],
                                createdByAdminId: "admin",
                                priority: selectedPriority,
                                isPinned: isPinned,
                              );
                              setState(() {
                                _allAnnouncements.insert(0, newNotice);
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: AppSpacing.md),
                                      const Text("Notice published successfully"),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                  margin: EdgeInsets.all(AppSpacing.lg),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAnnouncement(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text("Delete Announcement?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _allAnnouncements.remove(announcement);
                DummyData.announcements.remove(announcement);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      SizedBox(width: AppSpacing.md),
                      Text("Announcement deleted"),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  margin: EdgeInsets.all(AppSpacing.lg),
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
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
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 11,
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
  final VoidCallback onDelete;
  _AdminAnnouncementCard({required this.announcement, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
              SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: onDelete,
                tooltip: "Delete",
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(announcement.title, style: AppTextStyles.labelLarge),
          SizedBox(height: AppSpacing.xs),
          Text(
            announcement.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          Divider(height: AppSpacing.xl),
          Row(
            children: [
              CircleAvatar(
                radius: AppRadius.md,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(announcement.authorName[0], style: AppTextStyles.caption.copyWith(color: AppColors.navyBlueBase, fontSize: 10)),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                "By ${announcement.authorName}",
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                "${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}",
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
