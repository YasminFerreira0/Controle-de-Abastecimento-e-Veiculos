import 'package:flutter/material.dart';
import 'package:p2_andre/iu/screens/auth/login_screen.dart';
import 'package:p2_andre/iu/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../services/firebase_auth_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<FirebaseAuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'App com Firebase Auth',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,

        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
