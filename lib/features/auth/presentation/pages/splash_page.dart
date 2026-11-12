import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final storage = sl<LocalStorage>();
    final token = await storage.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      final userType = storage.getUserType();
      final userData = storage.getUserData();

      // Ensure the session is completely consistent (has token, userType, and user metadata)
      if (userType == AppConstants.userTypeTeacher && userData != null) {
        context.go('/teacher-home');
        return;
      } else if (userType == AppConstants.userTypeStudent && userData != null) {
        context.go('/home');
        return;
      } else {
        // Stale or corrupted session leftover from previous install or partial wipe.
        // Wipe cleanly and send to role select screen.
        await storage.clearUserSession();
        if (!mounted) return;
        context.go('/role-select');
        return;
      }
    } else {
      context.go('/role-select');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'مدارس نور الأردن الدولية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Noor Jordan International Schools',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
