import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class TeacherLoginPage extends StatefulWidget {
  const TeacherLoginPage({super.key});

  @override
  State<TeacherLoginPage> createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late List<AnimationController> _fieldControllers;
  late List<Animation<double>> _fieldFades;
  late List<Animation<Offset>> _fieldSlides;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
    _fieldControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _fieldFades = _fieldControllers.map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
    _fieldSlides = _fieldControllers.map((c) => Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();

    for (int i = 0; i < _fieldControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 100), () {
        if (mounted) _fieldControllers[i].forward();
      });
    }
  }

  Future<void> _loadFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (mounted) setState(() => _fcmToken = token);
      debugPrint('🔑 FCM TOKEN (Teacher Login Screen): $token');
    } catch (e) {
      debugPrint('⚠️ FCM Token Error: $e');
    }
  }

  @override
  void dispose() {
    _nationalIdCtrl.dispose();
    _passwordCtrl.dispose();
    for (final c in _fieldControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is TeacherAuthenticated) {
              context.go('/teacher-home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    _buildAnimatedField(
                      index: 0,
                      child: Column(children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'تسجيل دخول المعلم',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'أدخل بيانات حسابك للمتابعة',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 40),
                    _buildAnimatedField(
                      index: 1,
                      child: AppTextField(
                        label: 'الرقم الوطني',
                        hint: 'أدخل الرقم الوطني',
                        controller: _nationalIdCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                        validator: Validators.validateNationalId,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedField(
                      index: 2,
                      child: AppTextField(
                        label: 'كلمة المرور',
                        controller: _passwordCtrl,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                        validator: Validators.validatePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAnimatedField(
                      index: 3,
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) => AppButton(
                          label: 'تسجيل الدخول',
                          isAccent: true,
                          isLoading: state is AuthLoading,
                          onPressed: () => _submit(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                      label: const Text(
                        'العودة لاختيار الحساب',
                        style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    if (_fcmToken != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.vibration_rounded, size: 16, color: AppColors.accent),
                                    SizedBox(width: 6),
                                    Text(
                                      'FCM Token للجهاز:',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: _fcmToken!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ FCM Token بنجاح'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              _fcmToken!,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: AppColors.textPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fieldFades[index],
      child: SlideTransition(
        position: _fieldSlides[index],
        child: child,
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthCubit>().loginAsTeacher(
          nationalId: _nationalIdCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }
}
