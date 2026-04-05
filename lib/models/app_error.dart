import 'package:equatable/equatable.dart';

class AppError extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}
