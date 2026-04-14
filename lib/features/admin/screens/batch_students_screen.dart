import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class BatchStudentsScreen extends StatefulWidget {
  final BatchModel batch;
  
  const BatchStudentsScreen({
    super.key,
    required this.batch,
  });

  @override
  State<BatchStudentsScreen> createState() => _BatchStudentsScreenState();
}

class _BatchStudentsScreenState extends State<BatchStudentsScreen> {
  late List<StudentModel> _allStudents;
  late List<StudentModel> _batchStudents;
  late List<StudentModel> _availableStudents;

  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  void _refreshLists() {
    _allStudents = DummyData.students;
    _batchStudents = _allStudents.where((s) => s.batchId == widget.batch.id).toList();
    _availableStudents = _allStudents.where((s) => s.batchId != widget.batch.id).toList();
  }

  void _confirmRemove(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Student"),
        content: Text("Remove ${student.name} from ${widget.batch.name}?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                student.batchId = '';
                student.batchName = '';
                _refreshLists();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Student removed")),
              );
            },
            child: const Text("Yes, Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddStudentsSheet(
        batch: widget.batch,
        availableStudents: _availableStudents,
        onStudentsAssigned: (selectedIds) {
          setState(() {
            for (var student in _allStudents.where((s) => selectedIds.contains(s.id))) {
              student.batchId = widget.batch.id;
              student.batchName = widget.batch.name;
            }
            _refreshLists();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: widget.batch.name,
      subtitle: "Student Management",
      showBackButton: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentsSheet,
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text("Assign Students", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      headerWidgets: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            "${_batchStudents.length} Students Assigned",
            style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      body: _batchStudents.isEmpty
          ? const Column(
              children: [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.group_outlined,
                  title: "No students assigned",
                  subtitle: "Assign students to this batch",
                ),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 80),
              itemCount: _batchStudents.length,
              itemBuilder: (context, index) {
                final student = _batchStudents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.navyBlueSurface,
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyBlueBase),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: AppTextStyles.labelLarge),
                            Text(student.rollNumber.isEmpty ? 'No roll number' : student.rollNumber, style: AppTextStyles.caption),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                CourseBadge(courseType: student.courseType),
                                const SizedBox(width: AppSpacing.sm),
                                BranchBadge(branch: student.branch),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                        onPressed: () => _confirmRemove(student),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _AddStudentsSheet extends StatefulWidget {
  final BatchModel batch;
  final List<StudentModel> availableStudents;
  final Function(Set<String>) onStudentsAssigned;

  const _AddStudentsSheet({
    required this.batch,
    required this.availableStudents,
    required this.onStudentsAssigned,
  });

  @override
  State<_AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends State<_AddStudentsSheet> {
  final Set<String> _selectedStudents = {};
  late List<StudentModel> _filteredStudents;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filterStudents();
  }

  void _filterStudents() {
    if (_searchQuery.isEmpty) {
      _filteredStudents = List.from(widget.availableStudents);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredStudents = widget.availableStudents.where((s) {
        return s.name.toLowerCase().contains(q);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(

                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Assign Students", style: AppTextStyles.headingMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: CustomTextField(
                  hintText: "Search studens...",
                  prefixIcon: Icons.search,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _filterStudents();
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _filteredStudents.length,

                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    return CheckboxListTile(
                      value: _selectedStudents.contains(student.id),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedStudents.add(student.id);
                          } else {
                            _selectedStudents.remove(student.id);
                          }
                        });
                      },
                      title: Text(student.name, style: AppTextStyles.labelLarge),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xs),
                        child: Row(
                          children: [
                            CourseBadge(courseType: student.courseType),
                            SizedBox(width: AppSpacing.sm),
                            BranchBadge(branch: student.branch),
                          ],
                        ),
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: AppColors.navyBlueSurface,
                        child: Text(student.name[0], style: const TextStyle(color: AppColors.navyBlueBase)),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),

                child: CustomButton(
                  label: "Assign Selected (${_selectedStudents.length})",
                  width: double.infinity,
                  onPressed: _selectedStudents.isEmpty
                      ? null
                      : () {
                          widget.onStudentsAssigned(_selectedStudents);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Students assigned successfully")),
                          );
                        },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
