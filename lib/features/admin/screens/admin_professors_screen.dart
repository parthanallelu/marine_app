import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminProfessorsScreen extends StatefulWidget {
  const AdminProfessorsScreen({super.key});

  @override
  State<AdminProfessorsScreen> createState() => _AdminProfessorsScreenState();
}

class _AdminProfessorsScreenState extends State<AdminProfessorsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _specializationController = TextEditingController();

  List<ProfessorModel> _professors = [];
  String _searchQuery = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _professors = List.from(DummyData.professors);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  List<ProfessorModel> get _filteredProfessors {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _professors;
    return _professors.where((professor) {
      return professor.name.toLowerCase().contains(query) ||
          professor.email.toLowerCase().contains(query) ||
          professor.branch.toLowerCase().contains(query) ||
          professor.specialization.toLowerCase().contains(query);
    }).toList();
  }

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageShell(
      title: "Professors",
      subtitle: "Faculty management",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProfessorSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text(
          "Add Professor",
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      headerWidgets: [
        CustomTextField(
          hintText: "Search by name, email, branch...",
          prefixIcon: Icons.search_rounded,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          90,
        ),
        child: Column(
          children: [
            SectionHeader(
              title: "Faculty Directory",
              actionLabel: "${_filteredProfessors.length} found",
            ),
            const SizedBox(height: AppSpacing.md),
            if (_filteredProfessors.isEmpty)
              const EmptyState(
                icon: Icons.person_off_outlined,
                title: "No Professors Found",
                subtitle: "Add professors or adjust your search.",
              )
            else
              ..._filteredProfessors.map(
                (professor) => _ProfessorCard(
                  professor: professor,
                  onEdit: () => _showProfessorSheet(professor: professor),
                  onDelete: () => _confirmDeleteProfessor(professor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProfessor(ProfessorModel professor) {
    GenericConfirmationDialog.show(
      context,
      title: "Delete Professor",
      content:
          "Are you sure you want to delete ${professor.name}? Existing batches keep their current labels.",
      confirmLabel: "Delete",
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _professors.removeWhere((item) => item.id == professor.id);
          DummyData.professors.removeWhere((item) => item.id == professor.id);
          for (final batch in DummyData.batches) {
            if (batch.professorId == professor.id) {
              batch.professorId = '';
              batch.professorName = 'Unassigned';
            }
          }
        });
        AppSnackBar.showSuccess(context, "Professor deleted");
      },
    );
  }

  void _showProfessorSheet({ProfessorModel? professor}) {
    final isEditing = professor != null;
    final formKey = GlobalKey<FormState>();

    _nameController.text = professor?.name ?? '';
    _emailController.text = professor?.email ?? '';
    _phoneController.text = professor?.phone ?? '';
    _qualificationController.text = professor?.qualification ?? '';
    _experienceController.text = professor == null
        ? ''
        : professor.experienceYears.toString();
    _specializationController.text = professor?.specialization ?? '';

    String selectedBranch = professor?.branch ?? AppConstants.defaultBranch;
    final selectedSubjects = <String>{...?professor?.subjects};
    final selectedBatchIds = <String>{...?professor?.batchIds};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Edit Professor" : "Add Professor",
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomTextField(
                    label: "Full Name",
                    hintText: "Professor name",
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: "Email",
                    hintText: "faculty@academy.com",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) => value == null || !value.contains('@')
                        ? "Enter valid email"
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Phone",
                          hintText: "10-digit number",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) =>
                              value == null || value.length < 10
                              ? "Min 10 digits"
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: CustomTextField(
                          label: "Experience",
                          hintText: "Years",
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.timeline_rounded,
                          validator: (value) =>
                              int.tryParse(value ?? '') == null
                              ? "Invalid"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBranch,
                    decoration: const InputDecoration(
                      labelText: "Branch",
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                    items: AppConstants.branches
                        .map(
                          (branch) => DropdownMenuItem(
                            value: branch,
                            child: Text(branch),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => selectedBranch = value!,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: "Qualification",
                    hintText: "e.g. Master Mariner",
                    controller: _qualificationController,
                    prefixIcon: Icons.school_outlined,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: "Specialization",
                    hintText: "e.g. Navigation",
                    controller: _specializationController,
                    prefixIcon: Icons.workspace_premium_outlined,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text("Subjects", style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AppConstants.materialCategories.map((subject) {
                      return FilterChip(
                        label: Text(subject),
                        selected: selectedSubjects.contains(subject),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedSubjects.add(subject);
                            } else {
                              selectedSubjects.remove(subject);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text("Assigned Batches", style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: DummyData.batches.map((batch) {
                      return FilterChip(
                        label: Text(batch.name),
                        selected: selectedBatchIds.contains(batch.id),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedBatchIds.add(batch.id);
                            } else {
                              selectedBatchIds.remove(batch.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  CustomButton(
                    label: isEditing ? "Update Professor" : "Add Professor",
                    width: double.infinity,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedSubjects.isEmpty) {
                              AppSnackBar.showError(
                                context,
                                "Select at least one subject",
                              );
                              return;
                            }

                            _setSubmitting(true);
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            if (!mounted) return;

                            setState(() {
                              if (isEditing) {
                                professor.name = _nameController.text;
                                professor.email = _emailController.text;
                                professor.phone = _phoneController.text;
                                professor.branch = selectedBranch;
                                professor.subjects = selectedSubjects.toList();
                                professor.batchIds = selectedBatchIds.toList();
                                professor.qualification =
                                    _qualificationController.text;
                                professor.experienceYears = int.parse(
                                  _experienceController.text,
                                );
                                professor.specialization =
                                    _specializationController.text;
                                _syncBatchAssignments(professor);
                              } else {
                                final newProfessor = ProfessorModel(
                                  id: const Uuid().v4(),
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  phone: _phoneController.text,
                                  role: AppConstants.roleProfessor,
                                  branch: selectedBranch,
                                  createdAt: DateTime.now(),
                                  subjects: selectedSubjects.toList(),
                                  batchIds: selectedBatchIds.toList(),
                                  qualification: _qualificationController.text,
                                  experienceYears: int.parse(
                                    _experienceController.text,
                                  ),
                                  specialization:
                                      _specializationController.text,
                                );
                                DummyData.professors.insert(0, newProfessor);
                                _professors.insert(0, newProfessor);
                                _syncBatchAssignments(newProfessor);
                              }
                            });

                            _setSubmitting(false);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            AppSnackBar.showSuccess(
                              context,
                              isEditing
                                  ? "Professor updated"
                                  : "Professor added",
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _syncBatchAssignments(ProfessorModel professor) {
    for (final batch in DummyData.batches) {
      if (professor.batchIds.contains(batch.id)) {
        batch.professorId = professor.id;
        batch.professorName = professor.name;
      } else if (batch.professorId == professor.id) {
        batch.professorId = '';
        batch.professorName = 'Unassigned';
      }
    }
  }
}

class _ProfessorCard extends StatelessWidget {
  final ProfessorModel professor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfessorCard({
    required this.professor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: professor.name,
      subtitle: professor.specialization,
      icon: Icons.person_rounded,
      iconColor: AppColors.oceanBlue,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text("Edit"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "Delete",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.email_outlined,
            label: "Email",
            value: professor.email,
          ),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: "Branch",
            value: professor.branch,
          ),
          InfoRow(
            icon: Icons.timeline_rounded,
            label: "Experience",
            value: "${professor.experienceYears} years",
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: professor.subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navyBlueSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(subject, style: AppTextStyles.caption),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
