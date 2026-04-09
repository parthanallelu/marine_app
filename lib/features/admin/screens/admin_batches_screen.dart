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
  List<BatchModel> _allBatches = [];
  List<BatchModel> _filteredBatches = [];
  Map<String, List<BatchModel>> _groupedByBranch = {};
  Map<String, int> _batchStudentCounts = {};
  String _searchQuery = "";
  bool _isSubmitting = false;

  // Controllers promoted to class members for proper disposal
  final _nameController = TextEditingController();
  final _timingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      _allBatches = List.from(DummyData.batches);
      _processBatches();
    } catch (e) {
      debugPrint("Error loading batches: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timingController.dispose();
    super.dispose();
  }

  void _processBatches() {
    // Filter
    if (_searchQuery.isEmpty) {
      _filteredBatches = List.from(_allBatches);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredBatches = _allBatches.where((b) {
        return b.name.toLowerCase().contains(q) ||
            b.professorName.toLowerCase().contains(q) ||
            b.branch.toLowerCase().contains(q) ||
            b.courseType.toLowerCase().contains(q);
      }).toList();
    }

    // Group
    _groupedByBranch = {};
    for (final batch in _filteredBatches) {
      _groupedByBranch.putIfAbsent(batch.branch, () => []).add(batch);
    }

    // Pre-calculate student counts to avoid O(N*M) in build
    _batchStudentCounts = {};
    for (final batch in _filteredBatches) {
      _batchStudentCounts[batch.id] = DummyData.students.where((s) => s.batchId == batch.id).length;
    }
  }


  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }


    return AppPageShell(
      title: "Batch Management",
      subtitle: "Academy Schedule",
      showBackButton: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBatchSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Create Batch", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      headerWidgets: [
        CustomTextField(
          hintText: "Search by batch, professor, branch...",
          prefixIcon: Icons.search_rounded,
          onChanged: (val) => setState(() {
            _searchQuery = val;
            _processBatches();
          }),
        ),
      ],
      body: _filteredBatches.isEmpty
          ? const Column(
              children: [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.class_outlined,
                  title: "No Batches Created",
                  subtitle: "Create a batch to get started.",
                ),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 80),
              itemCount: _groupedByBranch.length,
              itemBuilder: (context, index) {
                final entry = _groupedByBranch.entries.elementAt(index);
                final branch = entry.key;
                final batchesInBranch = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.navyBlueBase, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            "$branch Branch",
                            style: AppTextStyles.headingSmall.copyWith(color: AppColors.navyBlueBase),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.navyBlueSurface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              "${batchesInBranch.length} Active",
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.navyBlueBase, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...batchesInBranch.map((batch) => BatchCard(
                          batch: batch,
                          studentCount: _batchStudentCounts[batch.id] ?? 0,
                          onManage: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BatchStudentsScreen(batch: batch)),
                            ).then((_) {
                              if (context.mounted) {
                                setState(() {
                                  _processBatches();
                                });
                              }
                            });
                          },
                          onEdit: () => _showEditBatchSheet(batch),
                          onDelete: () => _confirmDeleteBatch(batch),
                        )),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CREATE BATCH
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showCreateBatchSheet() {
    final formKey = GlobalKey<FormState>();
    _nameController.clear();
    _timingController.clear();
    String? selectedBranch;
    String? selectedCourse;
    String? selectedProfessor;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Create New Batch", style: AppTextStyles.headingMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Configure a new academic batch with schedule and instructor assignment.",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CustomTextField(
                          label: "Batch Name",
                          hintText: "e.g. Gamma Batch 2024",
                          controller: _nameController,
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => v == null || v.isEmpty ? "Batch name is required" : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Course", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                          items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => selectedCourse = val,
                          validator: (v) => v == null ? "Required" : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Branch", prefixIcon: Icon(Icons.location_on_outlined, size: 20)),
                          items: AppConstants.branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                          onChanged: (val) => selectedBranch = val,
                          validator: (v) => v == null ? "Required" : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Assigned Professor", prefixIcon: Icon(Icons.person_pin_outlined, size: 20)),
                          items: DummyData.professors.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => selectedProfessor = val,
                          validator: (v) => v == null ? "Required" : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomTextField(
                          label: "Class Timings",
                          hintText: "e.g. 09:00 AM - 01:00 PM",
                          controller: _timingController,
                          prefixIcon: Icons.schedule_outlined,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: AppSpacing.xl),
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
                              if (picked != null && context.mounted) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        CustomButton(
                          label: "Initialize Batch",
                          width: double.infinity,
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : () async {
                            if (formKey.currentState!.validate()) {
                              _setSubmitting(true);
                              
                              // Simulate network delay
                              await Future.delayed(const Duration(milliseconds: 800));
                              
                              if (!mounted) return;

                              final prof = DummyData.professors.firstWhere((p) => p.id == selectedProfessor, orElse: () => DummyData.professors.first);
                              final newBatch = BatchModel(
                                id: const Uuid().v4(),
                                name: _nameController.text,
                                courseType: selectedCourse!,
                                branch: selectedBranch!,
                                professorId: selectedProfessor!,
                                professorName: prof.name,
                                timing: _timingController.text,
                                days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                                startDate: selectedDate,
                                studentIds: [],
                              );
                              
                              setState(() {
                                _allBatches.insert(0, newBatch);
                                DummyData.batches.insert(0, newBatch);
                                _processBatches();
                              });
                              
                              _setSubmitting(false);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              AppSnackBar.showSuccess(context, "Batch created successfully");
                            } else {
                              AppSnackBar.showError(context, "Please fix the errors in the form");
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EDIT BATCH
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showEditBatchSheet(BatchModel batch) {
    final formKey = GlobalKey<FormState>();
    _nameController.text = batch.name;
    _timingController.text = batch.timing;
    String selectedBranch = batch.branch;
    String selectedCourse = batch.courseType;
    String selectedProfessor = batch.professorId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Edit Batch", style: AppTextStyles.headingMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Update ${batch.name}'s configuration.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CustomTextField(
                        label: "Batch Name",
                        hintText: "e.g. Gamma Batch 2024",
                        controller: _nameController,
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) => v == null || v.isEmpty ? "Batch name is required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Course", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                        initialValue: selectedCourse,
                        items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => selectedCourse = val!,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Branch", prefixIcon: Icon(Icons.location_on_outlined, size: 20)),
                        initialValue: selectedBranch,
                        items: AppConstants.branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => selectedBranch = val!,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Assigned Professor", prefixIcon: Icon(Icons.person_pin_outlined, size: 20)),
                        initialValue: selectedProfessor,
                        items: DummyData.professors.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (val) => selectedProfessor = val!,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Class Timings",
                        hintText: "e.g. 09:00 AM - 01:00 PM",
                        controller: _timingController,
                        prefixIcon: Icons.schedule_outlined,
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      CustomButton(
                        label: "Update Batch Configuration",
                        width: double.infinity,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : () async {
                          if (formKey.currentState!.validate()) {
                            _setSubmitting(true);
                            
                            // Simulate network delay
                            await Future.delayed(const Duration(milliseconds: 800));
                            
                            if (!mounted) return;

                            final prof = DummyData.professors.firstWhere((p) => p.id == selectedProfessor, orElse: () => DummyData.professors.first);
                            setState(() {
                              batch.name = _nameController.text;
                              batch.courseType = selectedCourse;
                              batch.branch = selectedBranch;
                              batch.professorId = selectedProfessor;
                              batch.professorName = prof.name;
                              batch.timing = _timingController.text;
                              // Update batchName for all students in this batch
                              for (var student in DummyData.students.where((s) => s.batchId == batch.id)) {
                                student.batchName = batch.name;
                              }
                              _processBatches();
                            });
                            
                            _setSubmitting(false);
                            Navigator.pop(context);
                            AppSnackBar.showSuccess(context, "Batch details updated");
                          } else {
                            AppSnackBar.showError(context, "Please fix the errors in the form");
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DELETE BATCH
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _confirmDeleteBatch(BatchModel batch) {
    final studentCount = DummyData.students.where((s) => s.batchId == batch.id).length;
    GenericConfirmationDialog.show(
      context,
      title: "Delete Batch?",
      content: studentCount > 0 
        ? "This batch has $studentCount students. They will all become unassigned if you delete it."
        : "Are you sure you want to delete this batch? This action cannot be undone.",
      confirmLabel: "Delete",
      isDestructive: true,
      onConfirm: () {
        setState(() {
          // Unassign all students from this batch
          for (var student in DummyData.students.where((s) => s.batchId == batch.id)) {
            student.batchId = '';
            student.batchName = '';
          }
          _allBatches.removeWhere((b) => b.id == batch.id); // Also remove from local list
          DummyData.batches.removeWhere((b) => b.id == batch.id);
          _processBatches();
        });
        AppSnackBar.showSuccess(context, "Batch deleted successfully");
      },
    );
  }
}
