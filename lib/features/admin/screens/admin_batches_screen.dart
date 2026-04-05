import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import 'batch_students_screen.dart';

class AdminBatchesScreen extends StatefulWidget {
  const AdminBatchesScreen({super.key});

  @override
  State<AdminBatchesScreen> createState() => _AdminBatchesScreenState();
}

class _AdminBatchesScreenState extends State<AdminBatchesScreen> {
  late List<BatchModel> _allBatches;

  @override
  void initState() {
    super.initState();
    _allBatches = List.from(DummyData.batches);
  }

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: AppConstants.branches.length,
        itemBuilder: (context, index) {
          final branch = AppConstants.branches[index];
          final batchesInBranch = _allBatches.where((b) => b.branch == branch).toList();
          
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.navyBlueSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${batchesInBranch.length} Active",
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              ...batchesInBranch.map((batch) => _AdminBatchCard(
                    batch: batch,
                    onManageStudents: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BatchStudentsScreen(batch: batch)),
                      ).then((_) {
                        if (context.mounted) {
                          setState(() {});
                        }
                      });
                    },
                  )),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBatchSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Create Batch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateBatchSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final timingController = TextEditingController();
    String? selectedBranch;
    String? selectedCourse;
    String? selectedProfessor;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Create New Batch", style: AppTextStyles.headingMedium),
                      const SizedBox(height: 8),
                      Text(
                        "Configure a new academic batch with schedule and instructor assignment.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: "Batch Name",
                        hintText: "e.g. Gamma Batch 2024",
                        controller: nameController,
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Course", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                        items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => selectedCourse = val,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Branch", prefixIcon: Icon(Icons.location_on_outlined, size: 20)),
                        items: AppConstants.branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => selectedBranch = val,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Assigned Professor", prefixIcon: Icon(Icons.person_pin_outlined, size: 20)),
                        items: DummyData.professors.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (val) => selectedProfessor = val,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Class Timings",
                        hintText: "e.g. 09:00 AM - 01:00 PM",
                        controller: timingController,
                        prefixIcon: Icons.schedule_outlined,
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Start Date", style: AppTextStyles.labelLarge),
                        subtitle: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today_rounded, color: AppColors.navyBlueBase),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              // Small hack to rebuild bottom sheet state
                              // In a real app we'd use a Stateful builder or proper state management
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        label: "Initialize Batch",
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final prof = DummyData.professors.firstWhere((p) => p.id == selectedProfessor);
                            final newBatch = BatchModel(
                              id: const Uuid().v4(),
                              name: nameController.text,
                              courseType: selectedCourse!,
                              branch: selectedBranch!,
                              professorId: selectedProfessor!,
                              professorName: prof.name,
                              timing: timingController.text,
                              days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                              startDate: selectedDate,
                              studentIds: [],
                            );
                            setState(() {
                              _allBatches.insert(0, newBatch);
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Batch created successfully!")),
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
    );
  }
}

class _AdminBatchCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onManageStudents;
  const _AdminBatchCard({required this.batch, required this.onManageStudents});

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
                child: const Icon(Icons.class_outlined, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name, style: AppTextStyles.labelLarge),
                    Text(batch.courseType, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              CourseBadge(courseType: batch.courseType),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _BatchMeta(icon: Icons.person_pin_outlined, label: batch.professorName),
              const Spacer(),
              _BatchMeta(icon: Icons.access_time_rounded, label: batch.timing),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BatchMeta(icon: Icons.people_alt_outlined, label: "${DummyData.students.where((s) => s.batchId == batch.id).length} Students enrolled"),
              const Spacer(),
              TextButton.icon(
                onPressed: onManageStudents,
                icon: const Icon(Icons.group_rounded, size: 18),
                label: const Text("Manage Students"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navyBlueBase,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
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
        Icon(icon, size: 14, color: AppColors.oceanBlue),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
