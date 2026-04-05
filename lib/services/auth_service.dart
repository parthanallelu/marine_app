import '../models/app_models.dart';

/// Abstract interface for authentication operations.
abstract class AuthService {
  /// Streams the current user's authentication state.
  Stream<UserModel?> get userStateChanges;

  /// Signs in with email and password.
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Signs up a new user.
  Future<UserModel> signUp(UserModel user, String password);

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Current authenticated user ID.
  String? get currentUserId;
}
