import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../models/dummy_data.dart';
import '../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  String? _selectedRole;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  String? get selectedRole => _selectedRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // Helper Getters
  bool get isStudent => _currentUser != null && _currentUser!.role == AppConstants.roleStudent;
  bool get isProfessor => _currentUser != null && _currentUser!.role == AppConstants.roleProfessor;
  bool get isAdmin => _currentUser != null && _currentUser!.role == AppConstants.roleAdmin;

  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      if (_selectedRole == AppConstants.roleStudent) {
        final student = DummyData.students.firstWhere(
          (s) => s.email == email,
          orElse: () => DummyData.students.first, // Fallback to first student for demo
        );
        _currentUser = student;
      } else if (_selectedRole == AppConstants.roleProfessor) {
        final professor = DummyData.professors.firstWhere(
          (p) => p.email == email,
          orElse: () => DummyData.professors.first, // Fallback to first professor for demo
        );
        _currentUser = professor;
      } else if (_selectedRole == AppConstants.roleAdmin) {
        // Mock admin user
        _currentUser = UserModel(
          id: 'admin_001',
          name: 'Capt. Manaal',
          email: 'admin@academy.com',
          phone: '9988776655',
          role: AppConstants.roleAdmin,
          branch: 'Camp',
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Please select a role');
      }

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _isLoggedIn = false;
    _selectedRole = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkLoginState() async {
    // For future persistence implementation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
