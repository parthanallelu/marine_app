import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  final router = AppRouter.createRouter(authProvider);
  
  runApp(MyApp(authProvider: authProvider, router: router));
}
