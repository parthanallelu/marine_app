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
  String _searchQuery = "";
  String _selectedBranch = "All";
  String _selectedCourse = "All";

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data for local session state
    _allStudents = List.from(DummyData.students);
  }

  List<StudentModel> get _filteredStudents {
    return _allStudents.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          s.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBranch = _selectedBranch == "All" || s.branch == _selectedBranch;
      final matchesCourse = _selectedCourse == "All" || s.courseType == _selectedCourse;
      return matchesSearch && matchesBranch && matchesCourse;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: Colors.white,
            child: Column(
              children: [
                CustomTextField(
                  hintText: "Search by name, roll no, or email...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        label: _selectedBranch,
                        icon: Icons.location_on_rounded,
                        onTap: () => _showBranchSelector(),
                      ),
                    ),
                    const SizedBox(width: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Found ${students.length} Students",
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
                ),
                if (_selectedBranch != "All" || _selectedCourse != "All" || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedBranch = "All";
                      _selectedCourse = "All";
                      _searchQuery = "";
                    }),
                    child: const Text("Clear All"),
                  ),
              ],
            ),
          ),

          // STUDENT LIST
          Expanded(
            child: students.isEmpty
                ? const EmptyState(
                    icon: Icons.person_off_rounded,
                    title: "No Students Found",
                    subtitle: "Try adjusting your filters or search terms.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Extra bottom padding for FAB
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _AdminStudentTile(student: student);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentSheet(),
        backgroundColor: AppColors.navyBlueBase,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text("Add Student", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddStudentSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final rollController = TextEditingController();
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
                      Text("Enroll New Student", style: AppTextStyles.headingMedium),
                      const SizedBox(height: 8),
                      Text(
                        "Fill in the details below to add a student to the academy database.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: "Full Name",
                        hintText: "Enter student's full name",
                        controller: nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Email Address",
                        hintText: "example@academy.com",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => v == null || !v.contains('@') ? "Invalid email" : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: "Phone",
                              hintText: "10-digit number",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: (v) => v == null || v.length < 10 ? "Invalid phone" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: "Roll Number",
                              hintText: "MA-2024-XXX",
                              controller: rollController,
                              prefixIcon: Icons.badge_outlined,
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
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
                        decoration: const InputDecoration(labelText: "Course Type", prefixIcon: Icon(Icons.school_outlined, size: 20)),
                        items: AppConstants.courseTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => selectedCourse = val,
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        label: "Add Student to Records",
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                              final newStudent = StudentModel(
                                id: const Uuid().v4(),
                                name: nameController.text,
                                email: emailController.text,
                                phone: phoneController.text,
                                parentPhone: phoneController.text, // Using student phone as a fallback
                                role: AppConstants.roleStudent,
                                branch: selectedBranch!,
                                courseType: selectedCourse!,
                                rollNumber: rollController.text,
                                batchId: "unassigned",
                                batchName: "Unassigned",
                                createdAt: DateTime.now(),
                                joiningDate: DateTime.now(),
                              );
                            setState(() {
                              _allStudents.insert(0, newStudent);
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Student added successfully!")),
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

  void _showBranchSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text("Filter by Branch", style: AppTextStyles.headingSmall),
          ),
          ...["All", ...AppConstants.branches].map((branch) => ListTile(
                title: Text(branch),
                leading: Radio<String>.adaptive(
                  value: branch,
                  groupValue: _selectedBranch,
                  onChanged: (val) {
                    setState(() => _selectedBranch = val!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() => _selectedBranch = branch);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text("Filter by Course", style: AppTextStyles.headingSmall),
          ),
          ...["All", ...AppConstants.courseTypes].map((course) => ListTile(
                title: Text(course),
                leading: Radio<String>.adaptive(
                  value: course,
                  groupValue: _selectedCourse,
                  onChanged: (val) {
                    setState(() => _selectedCourse = val!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() => _selectedCourse = course);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.navyBlueBase),
            const SizedBox(width: 8),
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

class _AdminStudentTile extends StatelessWidget {
  final StudentModel student;
  const _AdminStudentTile({required this.student});

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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : 'S',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyBlueBase),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.labelLarge),
                    Text(student.rollNumber, style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 14),
              ),
            ],
          ),
          const Divider(height: 24),
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
}
