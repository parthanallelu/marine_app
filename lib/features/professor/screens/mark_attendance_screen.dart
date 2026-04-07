import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../core/common_widgets/student_tile.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import '../../../providers/auth_provider.dart';

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
  bool _isSubmitting = false;

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _isSubmitting = value);
  }



  void _onBatchChanged(String? batchId) {
    if (batchId == null || batchId == _selectedBatch) return;
    
    setState(() {
      _selectedBatch = batchId;
      _isLoading = true;
      _resetAttendanceMap();
    });

    // Mock loading students for the batch
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
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

  void _resetAttendanceMap() {
    _attendance.clear();
    _students = [];
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now) ? now : _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Role security check
    if (!authProvider.isProfessor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          _buildHeader(authProvider),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  topRight: Radius.circular(AppRadius.xxl),
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

  Widget _buildHeader(AuthProvider authProvider) {
    final dateDisplay = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Batch Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBatch,
                hint: Text('Select Batch', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                dropdownColor: AppColors.navyBlueBase,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                isExpanded: true,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                items: DummyData.batches.where((b) => b.professorId == (authProvider.currentUser?.id ?? '')).map((batch) {
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    dateDisplay,
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded, color: Colors.white70, size: 18),
                ],
              ),
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
        _buildAttendanceListHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final status = _attendance[student.id] ?? AttendanceStatus.present;

              return StudentTile(
                name: student.name,
                rollNumber: student.rollNumber,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _statusToggle(student.id, AttendanceStatus.present, Icons.check_circle_rounded, AppColors.success, status == AttendanceStatus.present),
                    const SizedBox(width: AppSpacing.md),
                    _statusToggle(student.id, AttendanceStatus.absent, Icons.cancel_rounded, AppColors.absent, status == AttendanceStatus.absent),
                  ],
                ),
              );
            },
          ),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildAttendanceListHeader() {
    return Padding(
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
              const SizedBox(width: AppSpacing.sm),
              _bulkActionChip('All A', AppColors.absent, () => _markAll(AttendanceStatus.absent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          label: 'Submit Attendance',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _saveAttendance,
          width: double.infinity,
        ),
      ),
    );
  }


  Widget _bulkActionChip(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Text(
          label, 
          style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
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

  Future<void> _saveAttendance() async {
    // Final date validation check
    if (_selectedDate.isAfter(DateTime.now())) {
      AppSnackBar.showError(context, 'Cannot mark attendance for future dates.');
      return;
    }

    _setSubmitting(true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (!mounted) {
      _setSubmitting(false);
      return;
    }

    _setSubmitting(false);
    AppSnackBar.showSuccess(context, 'Attendance recorded successfully!');
    context.pop();
  }

}
