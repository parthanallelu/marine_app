import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';
import 'widgets/student_drawer.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  bool _isLoading = false;
  late AttendanceSummary _summary;
  late List<AttendanceRecord> _records;
  late Map<DateTime, AttendanceStatus> _statusMap;
  DateTime _focusedDay = DateTime.now().toUtc();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    setState(() => _isLoading = true);
    
    // TODO: Replace DummyData with Firestore query:
    // final attendanceData = await studentRepository.getStudentAttendance(studentId);
    
    final student = context.read<AuthProvider>().currentUser as StudentModel;
    _records = DummyData.generateAttendanceForStudent(
      student.id,
      student.name,
      student.batchId,
    );
    _summary = DummyData.attendanceSummaryFor(student.id, _records);
    
    _statusMap = {
      for (var record in _records)
        DateTime(record.date.year, record.date.month, record.date.day): record.status
    };

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Access Control Safety
    if (!authProvider.isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.roleSelectionName);
      });
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppPageShell(
      title: "My Attendance",
      subtitle: "${_summary.percentageLabel} overall attendance",
      showBackButton: false,
      showMenuButton: true,
      endDrawer: const StudentDrawer(),
      headerWidgets: [
        Row(
          children: [
            _AttendanceStat(
              label: "Present",
              value: _summary.presentDays.toString(),
              icon: Icons.check_circle_rounded,
              color: AppColors.present,
              isLight: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            _AttendanceStat(
              label: "Absent",
              value: _summary.absentDays.toString(),
              icon: Icons.cancel_rounded,
              color: AppColors.absent,
              isLight: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            _AttendanceStat(
              label: "Half Day",
              value: _summary.halfDays.toString(),
              icon: Icons.timelapse_rounded,
              color: AppColors.halfDay,
              isLight: true,
            ),
            const SizedBox(width: AppSpacing.sm),
            _AttendanceStat(
              label: "Total",
              value: _summary.totalDays.toString(),
              icon: Icons.calendar_month_rounded,
              color: Colors.white,
              isLight: true,
            ),
          ],
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Progress card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: AppRadius.cardRadius,
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Attendance Status", style: AppTextStyles.labelLarge),
                      Text(
                        _summary.percentageLabel,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _summary.percentage >= 75 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: _summary.percentage / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.navyBlueSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _summary.percentage >= AppConstants.attendanceWarning ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        _summary.percentage >= AppConstants.attendanceWarning ? "Excellent! 🚢" : "Be careful! ⚠️",
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      Text("Min: 75%", style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // TableCalendar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: AppRadius.cardRadius,
                boxShadow: AppShadows.card,
              ),
              child: TableCalendar(
                firstDay: DateTime.now().toUtc().subtract(const Duration(days: 90)),
                lastDay: DateTime.now().toUtc().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                availableGestures: AvailableGestures.horizontalSwipe,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  defaultTextStyle: AppTextStyles.bodyMedium,
                  weekendTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTextStyles.labelLarge,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final status = _statusMap[DateTime(day.year, day.month, day.day)];
                    if (status == null) return null;

                    Color color;
                    switch (status) {
                      case AttendanceStatus.present:
                        color = AppColors.present;
                        break;
                      case AttendanceStatus.absent:
                        color = AppColors.absent;
                        break;
                      case AttendanceStatus.halfDay:
                        color = AppColors.halfDay;
                        break;
                      case AttendanceStatus.holiday:
                        color = AppColors.oceanBlue;
                        break;
                    }

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withAlpha((0.15 * 255).round()),
                        border: Border.all(color: color.withAlpha((0.50 * 255).round())),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: AppTextStyles.labelMedium.copyWith(color: color),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Legend row
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AttendanceDot(color: AppColors.present, label: "Present"),
                SizedBox(width: AppSpacing.lg),
                AttendanceDot(color: AppColors.absent, label: "Absent"),
                SizedBox(width: AppSpacing.lg),
                AttendanceDot(color: AppColors.halfDay, label: "Half Day"),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLight;

  const _AttendanceStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isLight 
              ? Colors.white.withAlpha((0.1 * 255).round()) 
              : color.withAlpha((0.08 * 255).round()),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isLight 
                ? Colors.white.withAlpha((0.2 * 255).round()) 
                : color.withAlpha((0.2 * 255).round()),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isLight ? Colors.white : color, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(
                color: isLight ? Colors.white : color, 
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isLight ? Colors.white70 : color.withAlpha((0.8 * 255).round()), 
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
