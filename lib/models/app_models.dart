import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'base_model.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENUMS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum AttendanceStatus {
  present,
  absent,
  halfDay,
  holiday;

  static AttendanceStatus fromString(String status) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

enum FileType {
  pdf,
  video,
  image,
  link;

  static FileType fromString(String type) {
    return FileType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => FileType.link,
    );
  }
}

enum FeeStatus {
  paid,
  pending,
  partial,
  overdue;

  static FeeStatus fromString(String status) {
    return FeeStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => FeeStatus.pending,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODELS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ignore: must_be_immutable
class UserModel extends Equatable implements BaseModel {
  String id;
  String name;
  String email;
  String phone;
  String role;
  String? photoUrl;
  String branch;
  DateTime createdAt;
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.branch,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'branch': branch,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'],
      branch: map['branch'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc(),
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? photoUrl,
    String? branch,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, role, photoUrl, branch, createdAt, isActive];
}

// ignore: must_be_immutable
class AdminModel extends UserModel {
  AdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.photoUrl,
    required super.branch,
    required super.createdAt,
    super.isActive,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'],
      branch: map['branch'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc(),
      isActive: map['isActive'] ?? true,
    );
  }
}

// ignore: must_be_immutable
class StudentModel extends UserModel {
  String courseType;
  String batchId;
  String batchName;
  String rollNumber;
  String parentPhone;
  DateTime joiningDate;
  String targetCompany;

  StudentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.photoUrl,
    required super.branch,
    required super.createdAt,
    super.isActive,
    required this.courseType,
    required this.batchId,
    required this.batchName,
    required this.rollNumber,
    required this.parentPhone,
    required this.joiningDate,
    this.targetCompany = '',
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'courseType': courseType,
      'batchId': batchId,
      'batchName': batchName,
      'rollNumber': rollNumber,
      'parentPhone': parentPhone,
      'joiningDate': joiningDate.toIso8601String(),
      'targetCompany': targetCompany,
    });
    return map;
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    final user = UserModel.fromMap(map);
    return StudentModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      photoUrl: user.photoUrl,
      branch: user.branch,
      createdAt: user.createdAt,
      isActive: user.isActive,
      courseType: map['courseType'] ?? '',
      batchId: map['batchId'] ?? '',
      batchName: map['batchName'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      joiningDate: map['joiningDate'] != null
          ? DateTime.parse(map['joiningDate']).toUtc()
          : DateTime.now().toUtc(),
      targetCompany: map['targetCompany'] ?? '',
    );
  }

  @override
  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? photoUrl,
    String? branch,
    DateTime? createdAt,
    bool? isActive,
    String? courseType,
    String? batchId,
    String? batchName,
    String? rollNumber,
    String? parentPhone,
    DateTime? joiningDate,
    String? targetCompany,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      courseType: courseType ?? this.courseType,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      rollNumber: rollNumber ?? this.rollNumber,
      parentPhone: parentPhone ?? this.parentPhone,
      joiningDate: joiningDate ?? this.joiningDate,
      targetCompany: targetCompany ?? this.targetCompany,
    );
  }

  Color get courseColor {
    if (courseType.contains('11th')) return AppColors.course11th;
    if (courseType.contains('12th')) return AppColors.course12th;
    return AppColors.courseCrash;
  }

  String get courseShortLabel {
    if (courseType.contains('11th')) return '11th';
    if (courseType.contains('12th')) return '12th';
    return 'Crash';
  }

  @override
  List<Object?> get props => [
        ...super.props,
        courseType,
        batchId,
        batchName,
        rollNumber,
        parentPhone,
        joiningDate,
        targetCompany,
      ];
}

// ignore: must_be_immutable
class ProfessorModel extends UserModel {
  List<String> subjects;
  List<String> batchIds;
  String qualification;
  int experienceYears;
  String specialization;

  ProfessorModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.photoUrl,
    required super.branch,
    required super.createdAt,
    super.isActive,
    required this.subjects,
    required this.batchIds,
    required this.qualification,
    required this.experienceYears,
    required this.specialization,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'subjects': subjects,
      'batchIds': batchIds,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'specialization': specialization,
    });
    return map;
  }

  factory ProfessorModel.fromMap(Map<String, dynamic> map) {
    final user = UserModel.fromMap(map);
    return ProfessorModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      photoUrl: user.photoUrl,
      branch: user.branch,
      createdAt: user.createdAt,
      isActive: user.isActive,
      subjects: List<String>.from(map['subjects'] ?? []),
      batchIds: List<String>.from(map['batchIds'] ?? []),
      qualification: map['qualification'] ?? '',
      experienceYears: map['experienceYears'] ?? 0,
      specialization: map['specialization'] ?? '',
    );
  }

  @override
  ProfessorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? photoUrl,
    String? branch,
    DateTime? createdAt,
    bool? isActive,
    List<String>? subjects,
    List<String>? batchIds,
    String? qualification,
    int? experienceYears,
    String? specialization,
  }) {
    return ProfessorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      subjects: subjects ?? this.subjects,
      batchIds: batchIds ?? this.batchIds,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      specialization: specialization ?? this.specialization,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        subjects,
        batchIds,
        qualification,
        experienceYears,
        specialization,
      ];
}

// ignore: must_be_immutable
class BatchModel extends Equatable implements BaseModel {
  final String id;
  String name;
  String courseType;
  String professorId;
  String professorName;
  final List<String> studentIds;
  String branch;
  String timing;
  List<String> days;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  BatchModel({
    required this.id,
    required this.name,
    required this.courseType,
    required this.professorId,
    required this.professorName,
    required this.studentIds,
    required this.branch,
    required this.timing,
    required this.days,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  int get totalStudents => studentIds.length;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'courseType': courseType,
      'professorId': professorId,
      'professorName': professorName,
      'studentIds': studentIds,
      'branch': branch,
      'timing': timing,
      'days': days,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      courseType: map['courseType'] ?? '',
      professorId: map['professorId'] ?? '',
      professorName: map['professorName'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      branch: map['branch'] ?? '',
      timing: map['timing'] ?? '',
      days: List<String>.from(map['days'] ?? []),
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate']).toUtc()
          : DateTime.now().toUtc(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']).toUtc() : null,
      isActive: map['isActive'] ?? true,
    );
  }

  BatchModel copyWith({
    String? id,
    String? name,
    String? courseType,
    String? professorId,
    String? professorName,
    List<String>? studentIds,
    String? branch,
    String? timing,
    List<String>? days,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      courseType: courseType ?? this.courseType,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      studentIds: studentIds ?? this.studentIds,
      branch: branch ?? this.branch,
      timing: timing ?? this.timing,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        courseType,
        professorId,
        professorName,
        studentIds,
        branch,
        timing,
        days,
        startDate,
        endDate,
        isActive,
      ];
}

class AttendanceRecord extends Equatable implements BaseModel {
  final String id;
  final String studentId;
  final String studentName;
  final String batchId;
  final DateTime date;
  final AttendanceStatus status;
  final String? markedByProfessorId;
  final String? remarks;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.batchId,
    required this.date,
    required this.status,
    this.markedByProfessorId,
    this.remarks,
  });

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.present;
      case AttendanceStatus.absent:
        return AppColors.absent;
      case AttendanceStatus.halfDay:
        return AppColors.halfDay;
      case AttendanceStatus.holiday:
        return AppColors.course11th; // Using blue for holiday
    }
  }

  String get statusLabel {
    final name = status.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'batchId': batchId,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'markedByProfessorId': markedByProfessorId,
      'remarks': remarks,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      batchId: map['batchId'] ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date']).toUtc()
          : DateTime.now().toUtc(),
      status: AttendanceStatus.fromString(map['status'] ?? 'absent'),
      markedByProfessorId: map['markedByProfessorId'],
      remarks: map['remarks'],
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? batchId,
    DateTime? date,
    AttendanceStatus? status,
    String? markedByProfessorId,
    String? remarks,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      date: date ?? this.date,
      status: status ?? this.status,
      markedByProfessorId: markedByProfessorId ?? this.markedByProfessorId,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        batchId,
        date,
        status,
        markedByProfessorId,
        remarks,
      ];
}

class AttendanceSummary extends Equatable implements BaseModel {
  final String studentId;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int halfDays;

  const AttendanceSummary({
    required this.studentId,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.halfDays,
  });

  double get percentage {
    if (totalDays == 0) return 0.0;
    return ((presentDays + halfDays * 0.5) / totalDays) * 100;
  }

  String get percentageLabel => '${percentage.toStringAsFixed(1)}%';

  @override
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'halfDays': halfDays,
    };
  }

  factory AttendanceSummary.fromMap(Map<String, dynamic> map) {
    return AttendanceSummary(
      studentId: map['studentId'] ?? '',
      totalDays: map['totalDays'] ?? 0,
      presentDays: map['presentDays'] ?? 0,
      absentDays: map['absentDays'] ?? 0,
      halfDays: map['halfDays'] ?? 0,
    );
  }

  AttendanceSummary copyWith({
    String? studentId,
    int? totalDays,
    int? presentDays,
    int? absentDays,
    int? halfDays,
  }) {
    return AttendanceSummary(
      studentId: studentId ?? this.studentId,
      totalDays: totalDays ?? this.totalDays,
      presentDays: presentDays ?? this.presentDays,
      absentDays: absentDays ?? this.absentDays,
      halfDays: halfDays ?? this.halfDays,
    );
  }

  @override
  List<Object?> get props => [
        studentId,
        totalDays,
        presentDays,
        absentDays,
        halfDays,
      ];
}

class QuestionModel extends Equatable implements BaseModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final String subject;
  final String? imageUrl;

  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.subject,
    this.imageUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'subject': subject,
      'imageUrl': imageUrl,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'],
      subject: map['subject'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  QuestionModel copyWith({
    String? id,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
    String? subject,
    String? imageUrl,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      subject: subject ?? this.subject,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionText,
        options,
        correctOptionIndex,
        explanation,
        subject,
        imageUrl,
      ];
}

class TestModel extends Equatable implements BaseModel {
  final String id;
  final String title;
  final String type;
  final String subject;
  final String? batchId;
  final String? companyTarget;
  final List<QuestionModel> questions;
  final int durationMinutes;
  final DateTime scheduledDate;
  final String createdByProfessorId;
  final bool isActive;
  final double totalMarks;
  final double passingMarks;

  const TestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.subject,
    this.batchId,
    this.companyTarget,
    required this.questions,
    required this.durationMinutes,
    required this.scheduledDate,
    required this.createdByProfessorId,
    this.isActive = true,
    required this.totalMarks,
    required this.passingMarks,
  });

  int get totalQuestions => questions.length;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'subject': subject,
      'batchId': batchId,
      'companyTarget': companyTarget,
      'questions': questions.map((q) => q.toMap()).toList(),
      'durationMinutes': durationMinutes,
      'scheduledDate': scheduledDate.toIso8601String(),
      'createdByProfessorId': createdByProfessorId,
      'isActive': isActive,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      subject: map['subject'] ?? '',
      batchId: map['batchId'],
      companyTarget: map['companyTarget'],
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(q))
          .toList(),
      durationMinutes: map['durationMinutes'] ?? 0,
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate']).toUtc()
          : DateTime.now().toUtc(),
      createdByProfessorId: map['createdByProfessorId'] ?? '',
      isActive: map['isActive'] ?? true,
      totalMarks: (map['totalMarks'] ?? 0).toDouble(),
      passingMarks: (map['passingMarks'] ?? 0).toDouble(),
    );
  }

  TestModel copyWith({
    String? id,
    String? title,
    String? type,
    String? subject,
    String? batchId,
    String? companyTarget,
    List<QuestionModel>? questions,
    int? durationMinutes,
    DateTime? scheduledDate,
    String? createdByProfessorId,
    bool? isActive,
    double? totalMarks,
    double? passingMarks,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      batchId: batchId ?? this.batchId,
      companyTarget: companyTarget ?? this.companyTarget,
      questions: questions ?? this.questions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdByProfessorId: createdByProfessorId ?? this.createdByProfessorId,
      isActive: isActive ?? this.isActive,
      totalMarks: totalMarks ?? this.totalMarks,
      passingMarks: passingMarks ?? this.passingMarks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        subject,
        batchId,
        companyTarget,
        questions,
        durationMinutes,
        scheduledDate,
        createdByProfessorId,
        isActive,
        totalMarks,
        passingMarks,
      ];
}

class TestResult extends Equatable implements BaseModel {
  final String id;
  final String testId;
  final String testTitle;
  final String studentId;
  final Map<String, int> answers;
  final double score;
  final double totalMarks;
  final int timeTakenSeconds;
  final DateTime submittedAt;
  final bool isPassed;

  const TestResult({
    required this.id,
    required this.testId,
    required this.testTitle,
    required this.studentId,
    required this.answers,
    required this.score,
    required this.totalMarks,
    required this.timeTakenSeconds,
    required this.submittedAt,
    required this.isPassed,
  });

  double get percentage => (score / totalMarks) * 100;
  String get percentageLabel => '${percentage.toStringAsFixed(1)}%';

  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B+';
    if (p >= 60) return 'B';
    if (p >= 50) return 'C';
    return 'F';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'testTitle': testTitle,
      'studentId': studentId,
      'answers': answers,
      'score': score,
      'totalMarks': totalMarks,
      'timeTakenSeconds': timeTakenSeconds,
      'submittedAt': submittedAt.toIso8601String(),
      'isPassed': isPassed,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'] ?? '',
      testId: map['testId'] ?? '',
      testTitle: map['testTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      answers: Map<String, int>.from(map['answers'] ?? {}),
      score: (map['score'] ?? 0).toDouble(),
      totalMarks: (map['totalMarks'] ?? 0).toDouble(),
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      submittedAt: map['submittedAt'] != null
          ? DateTime.parse(map['submittedAt']).toUtc()
          : DateTime.now().toUtc(),
      isPassed: map['isPassed'] ?? false,
    );
  }

  TestResult copyWith({
    String? id,
    String? testId,
    String? testTitle,
    String? studentId,
    Map<String, int>? answers,
    double? score,
    double? totalMarks,
    int? timeTakenSeconds,
    DateTime? submittedAt,
    bool? isPassed,
  }) {
    return TestResult(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      testTitle: testTitle ?? this.testTitle,
      studentId: studentId ?? this.studentId,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      totalMarks: totalMarks ?? this.totalMarks,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      submittedAt: submittedAt ?? this.submittedAt,
      isPassed: isPassed ?? this.isPassed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        testId,
        testTitle,
        studentId,
        answers,
        score,
        totalMarks,
        timeTakenSeconds,
        submittedAt,
        isPassed,
      ];
}

class StudyMaterialModel extends Equatable implements BaseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subject;
  final String fileUrl;
  final FileType fileType;
  final String uploadedByProfessorId;
  final String uploaderName;
  final DateTime uploadedAt;
  final List<String> targetCourses;
  final String? companyTarget;
  final double? fileSizeKb;

  const StudyMaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subject,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedByProfessorId,
    required this.uploaderName,
    required this.uploadedAt,
    required this.targetCourses,
    this.companyTarget,
    this.fileSizeKb,
  });

  String get fileSizeLabel {
    if (fileSizeKb == null) return '';
    if (fileSizeKb! < 1024) return '${fileSizeKb!.toStringAsFixed(1)} KB';
    return '${(fileSizeKb! / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subject': subject,
      'fileUrl': fileUrl,
      'fileType': fileType.toString().split('.').last,
      'uploadedByProfessorId': uploadedByProfessorId,
      'uploaderName': uploaderName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'targetCourses': targetCourses,
      'companyTarget': companyTarget,
      'fileSizeKb': fileSizeKb,
    };
  }

  factory StudyMaterialModel.fromMap(Map<String, dynamic> map) {
    return StudyMaterialModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subject: map['subject'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: FileType.fromString(map['fileType'] ?? 'link'),
      uploadedByProfessorId: map['uploadedByProfessorId'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.parse(map['uploadedAt']).toUtc()
          : DateTime.now().toUtc(),
      targetCourses: List<String>.from(map['targetCourses'] ?? []),
      companyTarget: map['companyTarget'],
      fileSizeKb: (map['fileSizeKb'] ?? 0).toDouble(),
    );
  }

  StudyMaterialModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subject,
    String? fileUrl,
    FileType? fileType,
    String? uploadedByProfessorId,
    String? uploaderName,
    DateTime? uploadedAt,
    List<String>? targetCourses,
    String? companyTarget,
    double? fileSizeKb,
  }) {
    return StudyMaterialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      uploadedByProfessorId: uploadedByProfessorId ?? this.uploadedByProfessorId,
      uploaderName: uploaderName ?? this.uploaderName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      targetCourses: targetCourses ?? this.targetCourses,
      companyTarget: companyTarget ?? this.companyTarget,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        subject,
        fileUrl,
        fileType,
        uploadedByProfessorId,
        uploaderName,
        uploadedAt,
        targetCourses,
        companyTarget,
        fileSizeKb,
      ];
}

class FeeInstallment extends Equatable implements BaseModel {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final FeeStatus status;
  final String? receiptNumber;
  final String? paymentMode;

  const FeeInstallment({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.receiptNumber,
    this.paymentMode,
  });

  Color get statusColor {
    switch (status) {
      case FeeStatus.paid:
        return const Color(0xFF2E7D32);
      case FeeStatus.pending:
        return const Color(0xFFF57F17);
      case FeeStatus.partial:
        return const Color(0xFF0066CC);
      case FeeStatus.overdue:
        return const Color(0xFFC62828);
    }
  }

  String get statusLabel {
    final name = status.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'receiptNumber': receiptNumber,
      'paymentMode': paymentMode,
    };
  }

  factory FeeInstallment.fromMap(Map<String, dynamic> map) {
    return FeeInstallment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate']).toUtc()
          : DateTime.now().toUtc(),
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']).toUtc() : null,
      status: FeeStatus.fromString(map['status'] ?? 'pending'),
      receiptNumber: map['receiptNumber'],
      paymentMode: map['paymentMode'],
    );
  }

  FeeInstallment copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    FeeStatus? status,
    String? receiptNumber,
    String? paymentMode,
  }) {
    return FeeInstallment(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        dueDate,
        paidDate,
        status,
        receiptNumber,
        paymentMode,
      ];
}

class FeeRecord extends Equatable implements BaseModel {
  final String id;
  final String studentId;
  final String studentName;
  final String batchId;
  final double totalFees;
  final double paidAmount;
  final List<FeeInstallment> installments;

  const FeeRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.batchId,
    required this.totalFees,
    required this.paidAmount,
    required this.installments,
  });

  double get pendingAmount => totalFees - paidAmount;
  double get percentagePaid => (paidAmount / totalFees) * 100;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'batchId': batchId,
      'totalFees': totalFees,
      'paidAmount': paidAmount,
      'installments': installments.map((i) => i.toMap()).toList(),
    };
  }

  factory FeeRecord.fromMap(Map<String, dynamic> map) {
    return FeeRecord(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      batchId: map['batchId'] ?? '',
      totalFees: (map['totalFees'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      installments: (map['installments'] as List? ?? [])
          .map((i) => FeeInstallment.fromMap(i))
          .toList(),
    );
  }

  FeeRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? batchId,
    double? totalFees,
    double? paidAmount,
    List<FeeInstallment>? installments,
  }) {
    return FeeRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      totalFees: totalFees ?? this.totalFees,
      paidAmount: paidAmount ?? this.paidAmount,
      installments: installments ?? this.installments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        batchId,
        totalFees,
        paidAmount,
        installments,
      ];
}

class AnnouncementModel extends Equatable implements BaseModel {
  final String id;
  final String title;
  final String description;
  final String priority; // 'low', 'medium', 'high'
  final String createdByAdminId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> targetBranches;
  final List<String> targetCourses;
  final bool isPinned;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdByAdminId,
    required this.authorName,
    required this.createdAt,
    this.expiresAt,
    required this.targetBranches,
    required this.targetCourses,
    this.isPinned = false,
  });

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFF57F17);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'createdByAdminId': createdByAdminId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'targetBranches': targetBranches,
      'targetCourses': targetCourses,
      'isPinned': isPinned,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'low',
      createdByAdminId: map['createdByAdminId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc(),
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']).toUtc() : null,
      targetBranches: List<String>.from(map['targetBranches'] ?? []),
      targetCourses: List<String>.from(map['targetCourses'] ?? []),
      isPinned: map['isPinned'] ?? false,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? createdByAdminId,
    String? authorName,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? targetBranches,
    List<String>? targetCourses,
    bool? isPinned,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      targetBranches: targetBranches ?? this.targetBranches,
      targetCourses: targetCourses ?? this.targetCourses,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        createdByAdminId,
        authorName,
        createdAt,
        expiresAt,
        targetBranches,
        targetCourses,
        isPinned,
      ];
}
