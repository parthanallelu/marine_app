import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  BatchModel? _selectedBatch;
  final Map<String, AttendanceStatus> _attendanceMap = {};

  @override
  Widget build(BuildContext context) {
    final professor = context.watch<AuthProvider>().currentUser as ProfessorModel;
    final professorBatches = DummyData.batches.where((b) => b.professorId == professor.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Mark Attendance", style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.navyBlueBase,
      ),
      body: Column(
        children: [
          // BATCH SELECTION BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Batch", style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: professorBatches.length,
                    itemBuilder: (context, index) {
                      final batch = professorBatches[index];
                      final isSelected = _selectedBatch?.id == batch.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(batch.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBatch = selected ? batch : null;
                              if (selected) {
                                _initializeAttendance(batch);
                              } else {
                                _attendanceMap.clear();
                              }
                            });
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.navyBlueBase,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // STUDENT ATTENDANCE LIST
          Expanded(
            child: _selectedBatch == null
                ? const EmptyState(
                    icon: Icons.groups_rounded,
                    title: "No Batch Selected",
                    subtitle: "Please select a batch from the list above to start marking attendance.",
                  )
                : _buildAttendanceList(),
          ),
          
          // SUBMIT BAR
          if (_selectedBatch != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                label: "Submit Attendance",
                onPressed: () => _showConfirmationDialog(),
              ),
            ),
        ],
      ),
    );
  }

  void _initializeAttendance(BatchModel batch) {
    _attendanceMap.clear();
    for (var stuId in batch.studentIds) {
      _attendanceMap[stuId] = AttendanceStatus.present;
    }
  }

  Widget _buildAttendanceList() {
    final studentsInBatch = DummyData.students.where((s) => _selectedBatch!.studentIds.contains(s.id)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${studentsInBatch.length} Students",
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    for (var id in _attendanceMap.keys) {
                      _attendanceMap[id] = AttendanceStatus.present;
                    }
                  });
                },
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text("Mark All Present"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: studentsInBatch.length,
            itemBuilder: (context, index) {
              final student = studentsInBatch[index];
              return _AttendanceTile(
                student: student,
                status: _attendanceMap[student.id]!,
                onChanged: (status) {
                  setState(() => _attendanceMap[student.id] = status);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog() {
    final absentCount = _attendanceMap.values.where((v) => v == AttendanceStatus.absent).length;
    final presentCount = _attendanceMap.values.where((v) => v == AttendanceStatus.present).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Batch: ${_selectedBatch!.name}"),
            const SizedBox(height: 8),
            Text("Present: $presentCount"),
            Text("Absent: $absentCount"),
            const SizedBox(height: 12),
            const Text("Are you sure you want to submit today's attendance?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Attendance submitted successfully!"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final StudentModel student;
  final AttendanceStatus status;
  final Function(AttendanceStatus) onChanged;

  const _AttendanceTile({
    required this.student,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
                radius: 20,
                backgroundColor: AppColors.navyBlueSurface,
                child: Text(student.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyBlueBase)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.labelLarge),
                    Text(student.rollNumber, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatusToggle(
                label: "Present",
                icon: Icons.check_circle_rounded,
                isSelected: status == AttendanceStatus.present,
                color: AppColors.success,
                onTap: () => onChanged(AttendanceStatus.present),
              ),
              _StatusToggle(
                label: "Absent",
                icon: Icons.cancel_rounded,
                isSelected: status == AttendanceStatus.absent,
                color: AppColors.error,
                onTap: () => onChanged(AttendanceStatus.absent),
              ),
              _StatusToggle(
                label: "Half Day",
                icon: Icons.timelapse_rounded,
                isSelected: status == AttendanceStatus.halfDay,
                color: AppColors.warning,
                onTap: () => onChanged(AttendanceStatus.halfDay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusToggle({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha((0.15 * 255).round()) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : AppColors.textHint),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
