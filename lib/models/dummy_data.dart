import 'app_models.dart';
import '../core/constants/app_constants.dart';

class DummyData {
  // Students
  static final List<StudentModel> students = [
    StudentModel(
      id: 'stu_001',
      name: 'Aditya Shinde',
      email: 'aditya@example.com',
      phone: '9876543210',
      role: AppConstants.roleStudent,
      branch: 'Camp',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      courseType: '12th Science',
      batchId: 'batch_001',
      batchName: 'Alpha Batch',
      rollNumber: 'MA-2024-001',
      parentPhone: '9876543211',
      joiningDate: DateTime.now().subtract(const Duration(days: 60)),
      targetCompany: 'Anglo-Eastern',
    ),
    StudentModel(
      id: 'stu_002',
      name: 'Rahul More',
      email: 'rahul@example.com',
      phone: '9876543212',
      role: AppConstants.roleStudent,
      branch: 'Pulgate',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      courseType: '11th Science',
      batchId: 'batch_002',
      batchName: 'Beta Batch',
      rollNumber: 'MA-2024-002',
      parentPhone: '9876543213',
      joiningDate: DateTime.now().subtract(const Duration(days: 45)),
    ),
    StudentModel(
      id: 'stu_003',
      name: 'Sneha Patil',
      email: 'sneha@example.com',
      phone: '9876543214',
      role: AppConstants.roleStudent,
      branch: 'Kondhwa',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      courseType: 'Crash Course (12th Passed)',
      batchId: 'batch_003',
      batchName: 'Gamma Batch',
      rollNumber: 'MA-2024-003',
      parentPhone: '9876543215',
      joiningDate: DateTime.now().subtract(const Duration(days: 30)),
      targetCompany: 'Synergy',
    ),
    StudentModel(
      id: 'stu_004',
      name: 'Vikram Singh',
      email: 'vikram@example.com',
      phone: '9876543216',
      role: AppConstants.roleStudent,
      branch: 'Dehu Road',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      courseType: '12th Science',
      batchId: 'batch_001',
      rollNumber: 'MA-2024-004',
      parentPhone: '9876543217',
      joiningDate: DateTime.now().subtract(const Duration(days: 20)),
      batchName: 'Alpha Batch',
    ),
    StudentModel(
      id: 'stu_005',
      name: 'Priyanka Deshmukh',
      email: 'priyanka@example.com',
      phone: '9876543218',
      role: AppConstants.roleStudent,
      branch: 'Camp',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      courseType: '11th Science',
      batchId: 'batch_002',
      rollNumber: 'MA-2024-005',
      parentPhone: '9876543219',
      joiningDate: DateTime.now().subtract(const Duration(days: 15)),
      batchName: 'Beta Batch',
    ),
    StudentModel(
      id: 'stu_006',
      name: 'Arjun Kulkarni',
      email: 'arjun@example.com',
      phone: '9876543220',
      role: AppConstants.roleStudent,
      branch: 'Pulgate',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      courseType: 'Crash Course (12th Passed)',
      batchId: 'batch_003',
      rollNumber: 'MA-2024-006',
      parentPhone: '9876543221',
      joiningDate: DateTime.now().subtract(const Duration(days: 10)),
      batchName: 'Gamma Batch',
    ),
  ];

  // Professors
  static final List<ProfessorModel> professors = [
    ProfessorModel(
      id: 'prof_001',
      name: 'Capt. Suresh Iyer',
      email: 'suresh@academy.com',
      phone: '9988776655',
      role: AppConstants.roleProfessor,
      branch: 'Camp',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      subjects: const ['IMU-CET', 'Maritime GK'],
      batchIds: const ['batch_001', 'batch_003'],
      qualification: 'Master Mariner',
      experienceYears: 15,
      specialization: 'Navigation & Ship Handling',
    ),
    ProfessorModel(
      id: 'prof_002',
      name: 'Dr. Meena Sharma',
      email: 'meena@academy.com',
      phone: '9988776644',
      role: AppConstants.roleProfessor,
      branch: 'Pulgate',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      subjects: const ['Mathematics', 'General Science'],
      batchIds: const ['batch_002'],
      qualification: 'PhD in Mathematics',
      experienceYears: 10,
      specialization: 'Physics & Applied Math',
    ),
    ProfessorModel(
      id: 'prof_003',
      name: 'Chief Engr. Rajesh Kumar',
      email: 'rajesh@academy.com',
      phone: '9988776633',
      role: AppConstants.roleProfessor,
      branch: 'Kondhwa',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      subjects: const ['Interview Prep', 'Psychometric'],
      batchIds: const ['batch_001', 'batch_002', 'batch_003'],
      qualification: 'MEO Class 1',
      experienceYears: 12,
      specialization: 'Marine Engineering',
    ),
  ];

  // Batches
  static final List<BatchModel> batches = [
    BatchModel(
      id: 'batch_001',
      name: 'Alpha Batch',
      courseType: '12th Science',
      professorId: 'prof_001',
      professorName: 'Capt. Suresh Iyer',
      studentIds: const ['stu_001', 'stu_004'],
      branch: 'Camp',
      timing: '09:00 AM - 01:00 PM',
      days: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      startDate: DateTime.now().subtract(const Duration(days: 60)),
    ),
    BatchModel(
      id: 'batch_002',
      name: 'Beta Batch',
      courseType: '11th Science',
      professorId: 'prof_002',
      professorName: 'Dr. Meena Sharma',
      studentIds: const ['stu_002', 'stu_005'],
      branch: 'Pulgate',
      timing: '02:00 PM - 06:00 PM',
      days: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      startDate: DateTime.now().subtract(const Duration(days: 45)),
    ),
    BatchModel(
      id: 'batch_003',
      name: 'Gamma Batch',
      courseType: 'Crash Course (12th Passed)',
      professorId: 'prof_003',
      professorName: 'Chief Engr. Rajesh Kumar',
      studentIds: const ['stu_003', 'stu_006'],
      branch: 'Kondhwa',
      timing: '10:00 AM - 04:00 PM',
      days: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // Tests
  static final List<TestModel> tests = [
    TestModel(
      id: 'test_001',
      title: 'IMU-CET Mock 1',
      type: 'Mock Test',
      subject: 'IMU-CET',
      batchId: 'batch_001',
      questions: const [],
      durationMinutes: 180,
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      createdByProfessorId: 'prof_001',
      totalMarks: 200,
      passingMarks: 100,
    ),
    TestModel(
      id: 'test_002',
      title: 'Mathematics Unit 1',
      type: 'Unit Test',
      subject: 'Mathematics',
      batchId: 'batch_002',
      questions: const [],
      durationMinutes: 60,
      scheduledDate: DateTime.now().subtract(const Duration(days: 5)),
      createdByProfessorId: 'prof_002',
      totalMarks: 50,
      passingMarks: 25,
    ),
    TestModel(
      id: 'test_003',
      title: 'Psychometric Evaluation',
      type: 'Assessment',
      subject: 'Psychometric',
      companyTarget: 'Synergy',
      questions: const [],
      durationMinutes: 45,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      createdByProfessorId: 'prof_003',
      totalMarks: 100,
      passingMarks: 60,
    ),
    TestModel(
      id: 'test_004',
      title: 'Physics Revision',
      type: 'Practice Test',
      subject: 'General Science',
      questions: const [],
      durationMinutes: 30,
      scheduledDate: DateTime.now().subtract(const Duration(days: 10)),
      createdByProfessorId: 'prof_002',
      totalMarks: 25,
      passingMarks: 12,
    ),
  ];

  // Test Results
  static final List<TestResult> testResults = [
    TestResult(
      id: 'res_001',
      testId: 'test_002',
      testTitle: 'Mathematics Unit 1',
      studentId: 'stu_001',
      answers: const {},
      score: 42,
      totalMarks: 50,
      timeTakenSeconds: 3200,
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      isPassed: true,
    ),
    TestResult(
      id: 'res_002',
      testId: 'test_004',
      testTitle: 'Physics Revision',
      studentId: 'stu_001',
      answers: const {},
      score: 22,
      totalMarks: 25,
      timeTakenSeconds: 1500,
      submittedAt: DateTime.now().subtract(const Duration(days: 10)),
      isPassed: true,
    ),
  ];

  // Materials
  static final List<StudyMaterialModel> materials = [
    StudyMaterialModel(
      id: 'mat_001',
      title: 'IMU-CET Physics Notes',
      description: 'Comprehensive notes for IMU-CET Physics section.',
      category: 'IMU-CET',
      subject: 'General Science',
      fileUrl: 'https://example.com/imu-physics.pdf',
      fileType: FileType.pdf,
      uploadedByProfessorId: 'prof_002',
      uploaderName: 'Dr. Meena Sharma',
      uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
      targetCourses: const ['11th Science', '12th Science'],
      fileSizeKb: 2048,
    ),
    StudyMaterialModel(
      id: 'mat_002',
      title: 'Interview Preparation Guide',
      description: 'Common interview questions for shipping companies.',
      category: 'Interview Prep',
      subject: 'Interview Prep',
      fileUrl: 'https://example.com/interview-guide.pdf',
      fileType: FileType.pdf,
      uploadedByProfessorId: 'prof_003',
      uploaderName: 'Chief Engr. Rajesh Kumar',
      uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
      targetCourses: const ['Crash Course (12th Passed)'],
      fileSizeKb: 1024,
    ),
    StudyMaterialModel(
      id: 'mat_003',
      title: 'Maritime GK Video 1',
      description: 'Introduction to maritime terminology.',
      category: 'Maritime GK',
      subject: 'Maritime GK',
      fileUrl: 'https://example.com/maritime-video.mp4',
      fileType: FileType.video,
      uploadedByProfessorId: 'prof_001',
      uploaderName: 'Capt. Suresh Iyer',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      targetCourses: const ['11th Science', '12th Science', 'Crash Course (12th Passed)'],
      fileSizeKb: 51200,
    ),
    StudyMaterialModel(
      id: 'mat_004',
      title: 'Synergy Selection Process',
      description: 'Detailed breakdown of Synergy selection rounds.',
      category: 'Interview Prep',
      subject: 'Interview Prep',
      fileUrl: 'https://example.com/synergy-guide.pdf',
      fileType: FileType.pdf,
      uploadedByProfessorId: 'prof_003',
      uploaderName: 'Chief Engr. Rajesh Kumar',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      targetCourses: const ['12th Science', 'Crash Course (12th Passed)'],
      companyTarget: 'Synergy',
      fileSizeKb: 512,
    ),
    StudyMaterialModel(
      id: 'mat_005',
      title: 'Mathematics Formula Sheet',
      description: 'Essential formulas for calculus and algebra.',
      category: 'IMU-CET',
      subject: 'Mathematics',
      fileUrl: 'https://example.com/math-formulas.pdf',
      fileType: FileType.pdf,
      uploadedByProfessorId: 'prof_002',
      uploaderName: 'Dr. Meena Sharma',
      uploadedAt: DateTime.now().subtract(const Duration(days: 60)),
      targetCourses: const ['11th Science', '12th Science'],
      fileSizeKb: 150,
    ),
  ];

  // Fee Records
  static final List<FeeRecord> feeRecords = [
    FeeRecord(
      id: 'fee_001',
      studentId: 'stu_001',
      studentName: 'Aditya Shinde',
      batchId: 'batch_001',
      totalFees: 75000,
      paidAmount: 50000,
      installments: [
        FeeInstallment(
          id: 'inst_001',
          title: 'Admission Fee',
          amount: 25000,
          dueDate: DateTime.now().subtract(const Duration(days: 60)),
          paidDate: DateTime.now().subtract(const Duration(days: 58)),
          status: FeeStatus.paid,
          receiptNumber: 'REC-1001',
          paymentMode: 'UPI',
        ),
        FeeInstallment(
          id: 'inst_002',
          title: 'First Installment',
          amount: 25000,
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
          paidDate: DateTime.now().subtract(const Duration(days: 25)),
          status: FeeStatus.paid,
          receiptNumber: 'REC-1025',
          paymentMode: 'Bank Transfer',
        ),
        FeeInstallment(
          id: 'inst_003',
          title: 'Second Installment',
          amount: 25000,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          status: FeeStatus.pending,
        ),
      ],
    ),
  ];

  // Announcements
  static final List<AnnouncementModel> announcements = [
    AnnouncementModel(
      id: 'ann_001',
      title: 'New Batch Starting Soon!',
      description: 'New Crash Course batch starts on 15th April at Pulgate branch.',
      priority: 'high',
      createdByAdminId: 'admin_001',
      authorName: 'Academy Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      targetBranches: const ['Pulgate'],
      targetCourses: const ['Crash Course (12th Passed)'],
      isPinned: true,
    ),
    AnnouncementModel(
      id: 'ann_002',
      title: 'Anglo-Eastern Recruitment',
      description: 'Anglo-Eastern will visit for campus placements on 20th May.',
      priority: 'medium',
      createdByAdminId: 'admin_001',
      authorName: 'Placement Cell',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      targetBranches: const ['Camp', 'Pulgate', 'Kondhwa', 'Dehu Road'],
      targetCourses: const ['12th Science', 'Crash Course (12th Passed)'],
    ),
    AnnouncementModel(
      id: 'ann_003',
      title: 'Holiday Notice: Gud Padwa',
      description: 'The academy will remain closed on the occasion of Gudi Padwa.',
      priority: 'low',
      createdByAdminId: 'admin_001',
      authorName: 'Academy Office',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      targetBranches: const ['Camp', 'Pulgate', 'Kondhwa', 'Dehu Road'],
      targetCourses: const ['11th Science', '12th Science', 'Crash Course (12th Passed)'],
    ),
    AnnouncementModel(
      id: 'ann_004',
      title: 'IMU-CET Application Open',
      description: 'IMU-CET June session application forms are now available online.',
      priority: 'high',
      createdByAdminId: 'admin_001',
      authorName: 'Academy Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      targetBranches: const ['Camp', 'Pulgate', 'Kondhwa', 'Dehu Road'],
      targetCourses: const ['12th Science', 'Crash Course (12th Passed)'],
    ),
  ];

  // Attendance Generation
  static List<AttendanceRecord> generateAttendanceForStudent(String studentId, String studentName, String batchId) {
    final List<AttendanceRecord> records = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.sunday) continue;

      final deterministicValue = (i + studentId.hashCode) % 10;
      AttendanceStatus status;
      if (deterministicValue < 8) {
        status = AttendanceStatus.present;
      } else if (deterministicValue == 8) {
        status = AttendanceStatus.absent;
      } else {
        status = AttendanceStatus.halfDay;
      }

      records.add(AttendanceRecord(
        id: 'att_${studentId}_$i',
        studentId: studentId,
        studentName: studentName,
        batchId: batchId,
        date: date,
        status: status,
      ));
    }
    return records;
  }

  static AttendanceSummary attendanceSummaryFor(String studentId, List<AttendanceRecord> records) {
    int total = 0;
    int present = 0;
    int absent = 0;
    int halfDay = 0;

    for (final record in records) {
      if (record.studentId == studentId) {
        total++;
        switch (record.status) {
          case AttendanceStatus.present:
            present++;
            break;
          case AttendanceStatus.absent:
            absent++;
            break;
          case AttendanceStatus.halfDay:
            halfDay++;
            break;
          case AttendanceStatus.holiday:
            break;
        }
      }
    }

    return AttendanceSummary(
      studentId: studentId,
      totalDays: total,
      presentDays: present,
      absentDays: absent,
      halfDays: halfDay,
    );
  }
}
