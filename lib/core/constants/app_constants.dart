class AppConstants {
  static const String appName = "Capt. Manaal's Marine";
  static const String appTagline = "Way to Right Guidance";
  
  static const List<String> branches = ['Camp', 'Pulgate', 'Kondhwa', 'Dehu Road'];
  
  static const List<String> courseTypes = [
    '11th Science',
    '12th Science',
    'Crash Course (12th Passed)',
  ];
  
  static const Map<String, String> courseLabels = {
    '11th Science': '11th Sci',
    '12th Science': '12th Sci',
    'Crash Course (12th Passed)': 'Crash',
  };
  
  static const List<String> shippingCompanies = [
    'Synergy',
    'MSC',
    'Anglo-Eastern',
    'V.Ships',
    'Fleet Management',
    'Maersk Line',
    'Great Eastern',
    'Wilhemsen',
    'Eastern Pacific',
    'K-Line',
    'Mitsui',
  ];
  
  static const List<String> materialCategories = [
    'IMU-CET',
    'Psychometric',
    'English Communication',
    'Maritime GK',
    'Interview Prep',
    'General Science',
    'Mathematics',
  ];
  
  static const String roleStudent = 'student';
  static const String roleProfessor = 'professor';
  static const String roleAdmin = 'admin';
  
  static const double attendanceGood = 85.0;
  static const double attendanceWarning = 75.0;
  static const double attendanceCritical = 60.0;
  
  // SharedPreferences keys
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';
}

class AppRoutes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  
  // Student
  static const String studentHome = '/student/home';
  static const String studentAttendance = '/student/attendance';
  static const String studentTests = '/student/tests';
  static const String studentMaterials = '/student/materials';
  static const String studentProfile = '/student/profile';
  static const String studentFees = '/student/profile/fees';
  static const String studentAnnouncements = '/student/profile/announcements';
  
  // Professor
  static const String professorHome = '/professor/home';
  static const String professorAttendance = '/professor/attendance';
  static const String markAttendance = '/professor/attendance/mark';
  static const String professorMaterials = '/professor/materials';
  static const String professorProfile = '/professor/profile';
  
  // Admin
  static const String adminHome = '/admin/home';
  static const String adminStudents = '/admin/students';
  static const String adminBatches = '/admin/batches';
  static const String adminFees = '/admin/fees';
  static const String adminAnnouncements = '/admin/announcements';
}
