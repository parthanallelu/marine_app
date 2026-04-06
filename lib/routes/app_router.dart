import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/student/screens/student_home_screen.dart';
import '../features/student/screens/student_attendance_screen.dart';
import '../features/student/screens/student_tests_screen.dart';
import '../features/student/screens/test_attempt_screen.dart';
import '../features/student/screens/test_result_screen.dart';
import '../features/student/screens/student_materials_screen.dart';
import '../features/student/screens/student_profile_screen.dart';
import '../features/student/screens/student_shell.dart';
import '../features/student/screens/student_announcements_screen.dart';
import '../features/professor/screens/professor_home_screen.dart';
import '../features/professor/screens/mark_attendance_screen.dart';
import '../features/professor/screens/professor_materials_screen.dart';
import '../features/professor/screens/professor_tests_screen.dart';
import '../features/professor/screens/professor_profile_screen.dart';
import '../features/professor/screens/professor_shell.dart';
import '../features/admin/screens/admin_home_screen.dart';
import '../features/admin/screens/admin_students_screen.dart';
import '../features/admin/screens/admin_batches_screen.dart';
import '../features/admin/screens/admin_fees_screen.dart';
import '../features/admin/screens/admin_announcements_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/common/screens/splash_screen.dart';
import '../features/common/screens/error_screen.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_constants.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: authProvider,
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => ErrorScreen(state: state),
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.matchedLocation;
        final role = authProvider.currentUser?.role;

        // Public paths that don't require authentication
        final isAuthPath = location == AppRoutes.roleSelection || 
                          location == AppRoutes.login || 
                          location == AppRoutes.splash;

        // 1. If not logged in and trying to access a private route, redirect to role-selection
        if (!isLoggedIn && !isAuthPath) {
          return AppRoutes.roleSelection;
        }

        // 2. If logged in and trying to access an auth page, redirect to their home
        if (isLoggedIn && isAuthPath && location != AppRoutes.splash) {
          if (authProvider.isStudent) return AppRoutes.studentHome;
          if (authProvider.isProfessor) return AppRoutes.professorHome;
          if (authProvider.isAdmin) return AppRoutes.adminHome;
        }

        // 3. Route Guards (RBAC)
        if (isLoggedIn) {
          // Student Guards
          if (role == AppConstants.roleStudent) {
            if (location.startsWith('/admin') || location.startsWith('/professor')) {
              return AppRoutes.studentHome;
            }
          }
          // Professor Guards
          if (role == AppConstants.roleProfessor) {
            if (location.startsWith('/admin') || location.startsWith('/student')) {
              return AppRoutes.professorHome;
            }
          }
          // Admin has access to all (No specific guard needed here unless admin shouldn't see certain student-only sub-pages)
        }

        return null;
      },
      routes: [
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // FLAT ROUTES
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.roleSelection,
          name: 'role_selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // STUDENT NAVIGATION (5 Branches)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => StudentShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.studentHome,
                  name: 'student_home',
                  builder: (context, state) => const StudentHomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.studentAttendance,
                  name: 'student_attendance',
                  builder: (context, state) => const StudentAttendanceScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.studentTests,
                  name: 'student_tests',
                  builder: (context, state) => const StudentTestsScreen(),
                  routes: [
                    GoRoute(
                      path: 'attempt/:testId',
                      name: 'test_attempt',
                      builder: (context, state) => TestAttemptScreen(
                        testId: state.pathParameters['testId'] ?? '',
                      ),
                    ),
                    GoRoute(
                      path: 'result/:resultId',
                      name: 'test_result',
                      builder: (context, state) => TestResultScreen(
                        resultId: state.pathParameters['resultId'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.studentMaterials,
                  name: 'student_materials',
                  builder: (context, state) => const StudentMaterialsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.studentProfile,
                  name: 'student_profile',
                  builder: (context, state) => const StudentProfileScreen(),
                  routes: [
                    GoRoute(
                      path: 'fees',
                      name: 'student_fees',
                      builder: (context, state) => const StudentFeesScreen(),
                    ),
                    GoRoute(
                      path: 'announcements',
                      name: 'student_announcements',
                      builder: (context, state) => const AnnouncementsScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // PROFESSOR NAVIGATION (4 Branches)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => ProfessorShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.professorHome,
                  name: 'professor_home',
                  builder: (context, state) => const ProfessorHomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.professorAttendance,
                  name: 'professor_attendance',
                  builder: (context, state) => const MarkAttendanceScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.professorTests,
                  name: 'professor_tests',
                  builder: (context, state) => const ProfessorTestsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.professorMaterials,
                  name: 'professor_materials',
                  builder: (context, state) => const ProfessorMaterialsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.professorProfile,
                  name: 'professor_profile',
                  builder: (context, state) => const ProfessorProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ADMIN NAVIGATION (5 Branches)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminHome,
                  name: 'admin_home',
                  builder: (context, state) => const AdminHomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminStudents,
                  name: 'admin_students',
                  builder: (context, state) => const AdminStudentsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminBatches,
                  name: 'admin_batches',
                  builder: (context, state) => const AdminBatchesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminFees,
                  name: 'admin_fees',
                  builder: (context, state) => const AdminFeesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminAnnouncements,
                  name: 'admin_announcements',
                  builder: (context, state) => const AdminAnnouncementsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
