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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    icon: Icons.campaign_rounded,
                    title: "No Active Notices",
                    subtitle: "No announcements have been broadcasted for this filter.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
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
        onPressed: () => _showCreateAnnouncementSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.campaign_rounded, color: Colors.white),
        label: const Text("Post Notice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Broadcast New Notice", style: AppTextStyles.headingMedium),
                        const SizedBox(height: 8),
                        Text(
                          "This message will be visible to selected students and staff.",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: "Title",
                          hintText: "Enter a concise heading",
                          controller: titleController,
                          prefixIcon: Icons.title_rounded,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: "Description",
                          hintText: "Detail your announcement here...",
                          controller: descController,
                          maxLines: 4,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
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
                            const SizedBox(width: 16),
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
                        const SizedBox(height: 16),
                        Text("Target Branches", style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ["All", ...AppConstants.branches].map((branch) {
                            final isSel = selectedBranches.contains(branch);
                            return FilterChip(
                              label: Text(branch, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : AppColors.textPrimary)),
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
                        const SizedBox(height: 32),
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
                                authorRole: AppConstants.roleAdmin,
                                priority: selectedPriority,
                                isPinned: isPinned,
                                targetBranches: selectedBranches,
                                targetRoles: ["student", "professor"],
                              );
                              setState(() {
                                _allAnnouncements.insert(0, newNotice);
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Notice published successfully!")),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navyBlueBase : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.navyBlueBase : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
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
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(announcement.authorName[0], style: const TextStyle(fontSize: 10, color: AppColors.navyBlueBase)),
              ),
              const SizedBox(width: 8),
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
