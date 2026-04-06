import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late List<StudentModel> _allStudents;
  late List<StudentModel> _filteredStudents;
  String _searchQuery = "";
  String _selectedBranch = "All";
  String _selectedCourse = "All";

  // Controllers promoted to class members for proper disposal
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _targetCompanyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allStudents = List.from(DummyData.students);
    _applyFilters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    _parentPhoneController.dispose();
    _targetCompanyController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _filteredStudents = _allStudents.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = s.name.toLowerCase().contains(q) ||
          s.rollNumber.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.phone.toLowerCase().contains(q) ||
          s.batchName.toLowerCase().contains(q);
      final matchesBranch = _selectedBranch == "All" || s.branch == _selectedBranch;
      final matchesCourse = _selectedCourse == "All" || s.courseType == _selectedCourse;
      return matchesSearch && matchesBranch && matchesCourse;
    }).toList();
  }


  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Student Directory", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // SEARCH & FILTER BAR
          Container(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            color: Colors.white,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Search by name, roll no, email, batch...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() {
                    _searchQuery = val;
                    _applyFilters();
                  }),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        label: _selectedBranch,
                        icon: Icons.location_on_rounded,
                        onTap: () => _showBranchSelector(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _FilterButton(
                        label: _selectedCourse,
                        icon: Icons.school_rounded,
                        onTap: () => _showCourseSelector(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STUDENT COUNT
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Found ${_filteredStudents.length} Students",
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
                ),
                if (_selectedBranch != "All" || _selectedCourse != "All" || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedBranch = "All";
                      _selectedCourse = "All";
                      _searchQuery = "";
                      _applyFilters();
                    }),
                    child: const Text("Clear All"),
                  ),
              ],
            ),
          ),

          // STUDENT LIST
          Expanded(
            child: _filteredStudents.isEmpty
                ? const EmptyState(
                    icon: Icons.school_outlined,
                    title: "No Students Found",
                    subtitle: "Add students to get started or adjust your filters.",
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 80),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _AdminStudentTile(
                        student: student,
                        onEdit: () => _showEditStudentSheet(student),
                        onDelete: () => _confirmDeleteStudent(student),
                        onBatchChanged: () => setState(() {
                          _applyFilters();
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text("Add Student", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ADD STUDENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showAddStudentSheet() {
    final formKey = GlobalKey<FormState>();
    
    // Reset controllers for new entry
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _rollController.clear();
    _parentPhoneController.clear();
    _targetCompanyController.clear();

    String? selectedBranch;
    String? selectedCourse;

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
        decoration: BoxDecoration(
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
                      Text("Enroll New Student", style: AppTextStyles.headingMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Fill in the details below to add a student to the academy database.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CustomTextField(
                        label: "Full Name",
                        hintText: "Enter student's full name",
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Email Address",
                        hintText: "example@academy.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => v == null || !v.contains('@') ? "Enter a valid email" : null,
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
                              validator: (v) => v == null || v.length < 10 ? "Min 10 digits" : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: CustomTextField(
                              label: "Roll Number",
                              hintText: "MA-2024-XXX",
                              controller: _rollController,
                              prefixIcon: Icons.badge_outlined,
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Parent Phone",
                        hintText: "Parent's 10-digit number",
                        controller: _parentPhoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.family_restroom_outlined,
                        validator: (v) => v == null || v.length < 10 ? "Min 10 digits" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Target Company (Optional)",
                        hintText: "e.g. Synergy, Anglo Eastern",
                        controller: _targetCompanyController,
                        prefixIcon: Icons.business_outlined,
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
                        decoration: const InputDecoration(labelText: "Course Type", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                        items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => selectedCourse = val,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      CustomButton(
                        label: "Add Student to Records",
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                              final newStudent = StudentModel(
                                id: const Uuid().v4(),
                                name: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                parentPhone: _parentPhoneController.text,
                                role: AppConstants.roleStudent,
                                branch: selectedBranch!,
                                courseType: selectedCourse!,
                                rollNumber: _rollController.text,
                                batchId: "",
                                batchName: "",
                                createdAt: DateTime.now(),
                                joiningDate: DateTime.now(),
                                targetCompany: _targetCompanyController.text,
                              );
                            setState(() {
                              _allStudents.insert(0, newStudent);
                              _applyFilters();
                            });
                            Navigator.pop(context);
                            _showSuccessSnackbar("Student enrolled successfully");
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
  // EDIT STUDENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showEditStudentSheet(StudentModel student) {
    final formKey = GlobalKey<FormState>();
    
    // Initialize class controllers with current student values
    _nameController.text = student.name;
    _emailController.text = student.email;
    _phoneController.text = student.phone;
    _rollController.text = student.rollNumber;
    _parentPhoneController.text = student.parentPhone;
    _targetCompanyController.text = student.targetCompany;

    String selectedBranch = student.branch;
    String selectedCourse = student.courseType;

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
                      Text("Edit Student", style: AppTextStyles.headingMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Update ${student.name}'s information below.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CustomTextField(
                        label: "Full Name",
                        hintText: "Enter student's full name",
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Email Address",
                        hintText: "example@academy.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => v == null || !v.contains('@') ? "Enter a valid email" : null,
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
                              validator: (v) => v == null || v.length < 10 ? "Min 10 digits" : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: CustomTextField(
                              label: "Roll Number",
                              hintText: "MA-2024-XXX",
                              controller: _rollController,
                              prefixIcon: Icons.badge_outlined,
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Parent Phone",
                        hintText: "Parent's 10-digit number",
                        controller: _parentPhoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.family_restroom_outlined,
                        validator: (v) => v == null || v.length < 10 ? "Min 10 digits" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomTextField(
                        label: "Target Company (Optional)",
                        hintText: "e.g. Synergy, Anglo Eastern",
                        controller: _targetCompanyController,
                        prefixIcon: Icons.business_outlined,
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
                        decoration: const InputDecoration(labelText: "Course Type", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                        initialValue: selectedCourse,
                        items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => selectedCourse = val!,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      CustomButton(
                        label: "Save Changes",
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              student.name = _nameController.text;
                              student.email = _emailController.text;
                              student.phone = _phoneController.text;
                              student.rollNumber = _rollController.text;
                              student.courseType = selectedCourse;
                              student.branch = selectedBranch;
                              student.parentPhone = _parentPhoneController.text;
                              student.targetCompany = _targetCompanyController.text;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                            _showSuccessSnackbar("Student updated successfully");
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
  // DELETE STUDENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _confirmDeleteStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text("Delete Student?"),
        content: Text(
          "Are you sure you want to remove ${student.name}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _allStudents.remove(student);
                DummyData.students.remove(student);
                _applyFilters();
              });
              Navigator.pop(context);
              _showSuccessSnackbar("Student deleted");
            },
            child: Text("Delete", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FILTER SELECTORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showBranchSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Text("Filter by Branch", style: AppTextStyles.headingSmall),
          ),
          ...["All", ...AppConstants.branches].map((branch) => ListTile(
                title: Text(branch),
                leading: Radio<String>.adaptive(
                  value: branch,
                  groupValue: _selectedBranch,
                  onChanged: (val) {
                    setState(() {
                      _selectedBranch = val!;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedBranch = branch;
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showCourseSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Text("Filter by Course", style: AppTextStyles.headingSmall),
          ),
          ...["All", ...AppConstants.courseTypes].map((course) => ListTile(
                title: Text(course),
                leading: Radio<String>.adaptive(
                  value: course,
                  groupValue: _selectedCourse,
                  onChanged: (val) {
                    setState(() {
                      _selectedCourse = val!;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedCourse = course;
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FILTER BUTTON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.navyBlueBase),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STUDENT TILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AdminStudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onBatchChanged;
  const _AdminStudentTile({
    required this.student,
    required this.onEdit,
    required this.onDelete,
    required this.onBatchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppRadius.xxl,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : 'S',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.navyBlueBase),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.labelLarge),
                    Text(student.rollNumber, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                tooltip: "Manage Student",
                onSelected: (val) {
                  switch (val) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'assign':
                      _showBatchSelector(context);
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: AppSpacing.sm),
                        const Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'batch',
                    child: Row(
                      children: [
                        const Icon(Icons.class_outlined, size: 18),
                        SizedBox(width: AppSpacing.sm),
                        const Text("Assign to Batch"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: AppSpacing.sm),
                        Text("Delete", style: AppTextStyles.labelMedium.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (student.batchId.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.class_outlined, size: 14, color: AppColors.gold),
                      SizedBox(width: AppSpacing.xs),
                      Text(student.batchName, style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                      SizedBox(width: AppSpacing.xs),
                      Text("Not Assigned", style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BranchBadge(branch: student.branch),
              CourseBadge(courseType: student.courseType),
            ],
          ),
        ],
      ),
    );
  }

  void _showBatchSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedBatchId;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: const Text("Assign Batch"),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Select Batch", prefixIcon: Icon(Icons.class_outlined, size: 20)),
            items: DummyData.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
            onChanged: (val) => selectedBatchId = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedBatchId != null) {
                  final batch = DummyData.batches.firstWhere((b) => b.id == selectedBatchId);
                  student.batchId = batch.id;
                  student.batchName = batch.name;
                  onBatchChanged();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: AppSpacing.md),
                          Text("Assigned to ${batch.name}"),
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
              child: Text("Assign", style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
