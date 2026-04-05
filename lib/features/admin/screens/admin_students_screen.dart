import 'package:flutter/material.dart';
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
  String _searchQuery = "";
  String _selectedBranch = "All";
  String _selectedCourse = "All";

  @override
  Widget build(BuildContext context) {
    final students = DummyData.students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBranch = _selectedBranch == "All" || s.branch == _selectedBranch;
      final matchesCourse = _selectedCourse == "All" || s.courseType == _selectedCourse;
      return matchesSearch && matchesBranch && matchesCourse;
    }).toList();

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
                  hintText: "Search by name or roll number...",
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
            padding: const EdgeInsets.all(16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _AdminStudentTile(student: student);
                    },
                  ),
          ),
        ],
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
                leading: Radio<String>(
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
                leading: Radio<String>(
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
                  student.name[0],
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
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.oceanBlue),
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
