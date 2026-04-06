import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

class ProfessorTestsScreen extends StatefulWidget {
  const ProfessorTestsScreen({super.key});

  @override
  State<ProfessorTestsScreen> createState() => _ProfessorTestsScreenState();
}

class _ProfessorTestsScreenState extends State<ProfessorTestsScreen> {
  late List<TestModel> _allTests;
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  void _loadTests() {
    // Simulate loading tests for the current professor
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    setState(() {
      _allTests = DummyData.tests.where((t) => t.createdByProfessorId == prof.id).toList();
      _isLoading = false;
    });
  }

  List<TestModel> get _filteredTests {
    if (_searchQuery.isEmpty) return _allTests;
    final q = _searchQuery.toLowerCase();
    return _allTests.where((t) {
      final batch = DummyData.batches.firstWhere((b) => b.id == t.batchId, orElse: () => DummyData.batches[0]);
      return t.title.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q) ||
          batch.name.toLowerCase().contains(q);
    }).toList();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.md),
            Expanded(child: const Text("Test successfully updated")),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tests = _filteredTests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Test Management", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            color: Colors.white,
            child: CustomTextField(
              hintText: "Search by title, subject, or batch...",
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // TEST LIST
          Expanded(
            child: tests.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    title: "No Tests Found",
                    subtitle: "Create a test to assess your students or adjust your search.",
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 80),
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      return _ProfessorTestCard(
                        test: test,
                        onDelete: () => _confirmDeleteTest(test),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTestSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("Create Test", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  void _confirmDeleteTest(TestModel test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text("Delete Test?"),
        content: Text("Are you sure you want to delete \"${test.title}\"? This will also remove all student attempts and results."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _allTests.remove(test);
                DummyData.tests.remove(test);
              });
              Navigator.pop(context);
              _showSuccessSnackbar("Test deleted successfully");
            },
            child: Text("Delete", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateTestSheet() {
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final marksController = TextEditingController();
    final durationController = TextEditingController();
    String? selectedBatch;
    String? selectedSubject = prof.subjects.isNotEmpty ? prof.subjects.first : null;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

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
                        Text("Create New Assessment", style: AppTextStyles.headingMedium),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          "Schedule a new test for your assigned batches.",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        CustomTextField(
                          label: "Test Title",
                          hintText: "e.g. Navigation Unit Mock 1",
                          controller: titleController,
                          prefixIcon: Icons.assignment_outlined,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSubject,
                          decoration: const InputDecoration(labelText: "Subject", prefixIcon: Icon(Icons.subject_rounded, size: 20)),
                          items: prof.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setModalState(() => selectedSubject = v),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Target Batch", prefixIcon: Icon(Icons.class_outlined, size: 20)),
                          items: DummyData.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                          onChanged: (v) => setModalState(() => selectedBatch = v),
                          validator: (v) => v == null ? "Required" : null,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Total Marks",
                                hintText: "e.g. 50",
                                controller: marksController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.score_outlined,
                                validator: (v) => v == null || int.tryParse(v) == null ? "Invalid" : null,
                              ),
                            ),
                            SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: CustomTextField(
                                label: "Duration (Mins)",
                                hintText: "e.g. 60",
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.timer_outlined,
                                validator: (v) => v == null || int.tryParse(v) == null ? "Invalid" : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Scheduled Date", style: AppTextStyles.labelLarge),
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
                                setModalState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxxl),
                        CustomButton(
                          label: "Publish Assessment",
                          width: double.infinity,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final newTest = TestModel(
                                id: const Uuid().v4(),
                                title: titleController.text,
                                type: "Academic",
                                subject: selectedSubject!,
                                batchId: selectedBatch!,
                                questions: [],
                                durationMinutes: int.parse(durationController.text),
                                scheduledDate: selectedDate,
                                createdByProfessorId: prof.id,
                                totalMarks: double.tryParse(marksController.text) ?? 0.0,
                                passingMarks: (double.tryParse(marksController.text) ?? 0.0) * 0.4,
                              );
                              setState(() {
                                _allTests.insert(0, newTest);
                                DummyData.tests.insert(0, newTest);
                              });
                              Navigator.pop(context);
                              _showSuccessSnackbar("Test scheduled successfully");
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
}

class _ProfessorTestCard extends StatelessWidget {
  final TestModel test;
  final VoidCallback onDelete;

  const _ProfessorTestCard({required this.test, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final batch = DummyData.batches.firstWhere((b) => b.id == test.batchId, orElse: () => DummyData.batches[0]);
    final isUpcoming = test.scheduledDate.isAfter(DateTime.now());

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
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: (isUpcoming ? AppColors.success : AppColors.textHint).withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  isUpcoming ? "UPCOMING" : "COMPLETED",
                  style: AppTextStyles.caption.copyWith(
                    color: isUpcoming ? AppColors.success : AppColors.textHint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(test.title, style: AppTextStyles.labelLarge),
          SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              const Icon(Icons.subject_rounded, size: 14, color: AppColors.textHint),
              SizedBox(width: AppSpacing.xs),
              Text(test.subject, style: AppTextStyles.caption),
              SizedBox(width: AppSpacing.lg),
              const Icon(Icons.class_outlined, size: 14, color: AppColors.textHint),
              SizedBox(width: AppSpacing.xs),
              Text(batch.name, style: AppTextStyles.caption),
            ],
          ),
          Divider(height: AppSpacing.xxl),
          Row(
            children: [
              _TestMeta(icon: Icons.calendar_today_outlined, label: "${test.scheduledDate.day}/${test.scheduledDate.month}"),
              SizedBox(width: AppSpacing.lg),
              _TestMeta(icon: Icons.timer_outlined, label: "${test.durationMinutes}m"),
              SizedBox(width: AppSpacing.lg),
              _TestMeta(icon: Icons.score_outlined, label: "${test.totalMarks} Marks"),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TestMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.navyBlueBase),
        SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
