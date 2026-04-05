import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';
import '../../../models/dummy_data.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
        context.goNamed('role_selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _records.isEmpty 
          ? const EmptyState(
              icon: Icons.calendar_today_rounded,
              title: "No Attendance Records",
              subtitle: "We don't have any attendance data for you yet.",
            )
          : CustomScrollView(
              slivers: [
                // SLIVER 1 — NavyHeader
                SliverToBoxAdapter(
                  child: NavyHeader(
                    title: "My Attendance",
                    subtitle: "${_summary.percentageLabel} overall attendance",
                  ),
                ),

                // SLIVER 2 — 4 stat chips
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _AttendanceStat(
                          label: "Present",
                          value: _summary.presentDays.toString(),
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        _AttendanceStat(
                          label: "Absent",
                          value: _summary.absentDays.toString(),
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 8),
                        _AttendanceStat(
                          label: "Half Day",
                          value: _summary.halfDays.toString(),
                          icon: Icons.timelapse_rounded,
                          color: const Color(0xFFF57F17),
                        ),
                        const SizedBox(width: 8),
                        _AttendanceStat(
                          label: "Total",
                          value: _summary.totalDays.toString(),
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.navyBlueBase,
                        ),
                      ],
                    ),
                  ),
                ),

                // SLIVER 3 — Progress card
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _summary.percentage / 100,
                              minHeight: 10,
                              backgroundColor: AppColors.navyBlueSurface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _summary.percentage >= 75 ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _summary.percentage >= 75 ? "Excellent! 🚢" : "Be careful! ⚠️",
                                style: AppTextStyles.bodySmall,
                              ),
                              const Spacer(),
                              const Text("Min: 75%", style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SLIVER 4 — TableCalendar
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.cardRadius,
                        boxShadow: AppShadows.card,
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now().toUtc().subtract(const Duration(days: 90)),
                        lastDay: DateTime.now().toUtc().add(const Duration(days: 30)),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(color: AppColors.navyBlueSurface, shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(color: AppColors.navyBlueBase, shape: BoxShape.circle),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: AppColors.navyBlueBase),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          formatButtonTextStyle: const TextStyle(color: AppColors.navyBlueBase),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.navyBlueBase),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.navyBlueBase),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final status = _statusMap[DateTime(day.year, day.month, day.day)];
                            if (status == null) return null;

                            Color color;
                            switch (status) {
                              case AttendanceStatus.present:
                                color = const Color(0xFF2E7D32);
                                break;
                              case AttendanceStatus.absent:
                                color = const Color(0xFFC62828);
                                break;
                              case AttendanceStatus.halfDay:
                                color = const Color(0xFFF57F17);
                                break;
                              case AttendanceStatus.holiday:
                                color = AppColors.oceanBlue;
                                break;
                            }

                            return Container(
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.15 * 255).round()),
                                border: Border.all(color: color.withAlpha((0.50 * 255).round())),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(color: color, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // SLIVER 5 — Legend row
                const SliverPadding(
                  padding: EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AttendanceDot(color: Color(0xFF2E7D32), label: "Present"),
                        SizedBox(width: 16),
                        AttendanceDot(color: Color(0xFFC62828), label: "Absent"),
                        SizedBox(width: 16),
                        AttendanceDot(color: Color(0xFFF57F17), label: "Half Day"),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AttendanceStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha((0.08 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.20 * 255).round())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: color.withAlpha((0.8 * 255).round()), fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
