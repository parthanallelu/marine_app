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
  List<TestModel> _allTests = [];
  List<TestModel> _filteredTestsResults = [];
  Map<String, BatchModel> _testBatches = {};
  String _searchQuery = "";
  bool _isLoading = true;
  bool _isSubmitting = false;

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }


  // Controllers promoted to class members for proper disposal
  final _titleController = TextEditingController();
  final _marksController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      _loadTests();
    } catch (e) {
      debugPrint("Error initializing tests screen: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _marksController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadTests() {
    // Simulate loading tests for the current professor
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    setState(() {
      _allTests = DummyData.tests.where((t) => t.createdByProfessorId == prof.id).toList();
      _processTests();
      _isLoading = false;
    });
  }

  void _processTests() {
    // Filter and Map
    _testBatches = {};
    final q = _searchQuery.toLowerCase();
    
    _filteredTestsResults = _allTests.where((t) {
      final batch = DummyData.batches.firstWhere((b) => b.id == t.batchId, orElse: () => DummyData.batches[0]);
      _testBatches[t.id] = batch;
      
      if (q.isEmpty) return true;
      
      return t.title.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q) ||
          batch.name.toLowerCase().contains(q);
    }).toList();
  }




  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              onChanged: (val) => setState(() {
                _searchQuery = val;
                _processTests();
              }),
            ),
          ),

          // TEST LIST
          Expanded(
            child: _filteredTestsResults.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    title: "No Tests Found",
                    subtitle: "Create a test to assess your students or adjust your search.",
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 80),
                    itemCount: _filteredTestsResults.length,
                    itemBuilder: (context, index) {
                      final test = _filteredTestsResults[index];
                      return TestCard(
                        test: test,
                        batchName: _testBatches[test.id]?.name,
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
    GenericConfirmationDialog.show(
      context,
      title: "Delete Assessment?",
      content: "Are you sure you want to delete \"${test.title}\"? This will also remove all student attempts and results. This action cannot be undone.",
      confirmLabel: "Delete",
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _allTests.remove(test);
          DummyData.tests.remove(test);
          _processTests();
        });
        AppSnackBar.showSuccess(context, "Assessment deleted successfully");
      },
    );
  }

  void _showCreateTestSheet() {
    final prof = Provider.of<AuthProvider>(context, listen: false).currentUser as ProfessorModel?;
    if (prof == null) return;

    final formKey = GlobalKey<FormState>();
    _titleController.clear();
    _marksController.clear();
    _durationController.clear();
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
                          controller: _titleController,
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
                                  controller: _marksController,
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
                                  controller: _durationController,
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
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : () async {
                            if (formKey.currentState!.validate()) {
                              _setSubmitting(true);
                              
                              // Simulate network delay
                              await Future.delayed(const Duration(milliseconds: 1000));
                              
                              if (!mounted) return;

                              final newTest = TestModel(
                                id: const Uuid().v4(),
                                title: _titleController.text,
                                type: "Academic",
                                subject: selectedSubject!,
                                batchId: selectedBatch!,
                                questions: [],
                                durationMinutes: int.parse(_durationController.text),
                                scheduledDate: selectedDate,
                                createdByProfessorId: prof.id,
                                totalMarks: double.tryParse(_marksController.text) ?? 0.0,
                                passingMarks: (double.tryParse(_marksController.text) ?? 0.0) * 0.4,
                              );
                              
                              setState(() {
                                _allTests.insert(0, newTest);
                                DummyData.tests.insert(0, newTest);
                                _processTests();
                              });
                              _setSubmitting(false);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              AppSnackBar.showSuccess(context, "Test scheduled successfully");
                            } else {
                              AppSnackBar.showError(context, "Please fix the errors in the form");
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

