import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  /// Generates a unique ID using UUID v4.
  static String generateId() => _uuid.v4();

  /// Generates a simple ID for development (e.g., student_123).
  static String generateSimpleId(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
}
