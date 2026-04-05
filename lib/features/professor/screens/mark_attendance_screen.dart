import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _selectedBatch;
  DateTime _selectedDate = DateTime.now();
  final Map<String, AttendanceStatus> _attendance = {};
  List<StudentModel> _students = [];
  bool _isLoading = false;

  void _onBatchChanged(String? batchId) {
    if (batchId == null) return;
    setState(() {
      _selectedBatch = batchId;
      _isLoading = true;
    });

    // Mock loading students for the batch
    Future.delayed(const Duration(milliseconds: 500), () {
      final batch = DummyData.batches.firstWhere((b) => b.id == batchId);
      setState(() {
        _students = DummyData.students.where((s) => batch.studentIds.contains(s.id)).toList();
        // Initialize all as present by default
        for (var s in _students) {
          _attendance[s.id] = AttendanceStatus.present;
        }
        _isLoading = false;
      });
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlueBase,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Batch Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBatch,
                      hint: const Text('Select Batch', style: TextStyle(color: Colors.white70)),
                      dropdownColor: AppColors.navyBlueBase,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: DummyData.batches.map((batch) {
                        return DropdownMenuItem(
                          value: batch.id,
                          child: Text(batch.name),
                        );
                      }).toList(),
                      onChanged: _onBatchChanged,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Date Selector
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_calendar_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAttendanceList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_selectedBatch == null) {
      return const EmptyState(
        icon: Icons.touch_app_rounded,
        title: 'Select a Batch',
        subtitle: 'Please select a batch above to mark attendance.',
      );
    }

    if (_students.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off_rounded,
        title: 'No Students',
        subtitle: 'No students enrolled in this batch.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STUDENTS (${_students.length})',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2),
              ),
              Row(
                children: [
                  _bulkActionChip('All P', AppColors.success, () => _markAll(AttendanceStatus.present)),
                  const SizedBox(width: 8),
                  _bulkActionChip('All A', AppColors.absent, () => _markAll(AttendanceStatus.absent)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final status = _attendance[student.id] ?? AttendanceStatus.present;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.cardRadius,
                  boxShadow: AppShadows.subtle,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.navyBlueSurface,
                    child: Text(student.name[0], style: const TextStyle(color: AppColors.navyBlueBase, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(student.name, style: AppTextStyles.labelLarge),
                  subtitle: Text('Roll: ${student.rollNumber}', style: AppTextStyles.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusToggle(student.id, AttendanceStatus.present, Icons.check_circle_rounded, AppColors.success, status == AttendanceStatus.present),
                      const SizedBox(width: 12),
                      _statusToggle(student.id, AttendanceStatus.absent, Icons.cancel_rounded, AppColors.absent, status == AttendanceStatus.absent),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
          child: SafeArea(
            top: false,
            child: CustomButton(
              label: 'Submit Attendance',
              onPressed: _saveAttendance,
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bulkActionChip(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statusToggle(String studentId, AttendanceStatus status, IconData icon, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _attendance[studentId] = status),
      child: Icon(
        icon,
        color: isSelected ? color : color.withAlpha((0.2 * 255).round()),
        size: 28,
      ),
    );
  }

  void _markAll(AttendanceStatus status) {
    setState(() {
      for (var s in _students) {
        _attendance[s.id] = status;
      }
    });
  }

  void _saveAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance submitted successfully!')),
    );
    context.pop();
  }
}
