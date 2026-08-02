import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../domain/entities/student_profile.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAvatar;
  bool _editing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _fillFields(StudentProfile p) {
    _nameCtrl.text = p.name;
    _phoneCtrl.text = p.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProfileCubit>()..loadProfile()),
        BlocProvider(create: (_) => sl<AuthCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) context.go('/role-select');
        },
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded || state is ProfileUpdated) {
              final p = state is ProfileLoaded ? state.profile : (state as ProfileUpdated).profile;
              _fillFields(p);
              if (state is ProfileUpdated) {
                setState(() => _editing = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تم حفظ التغييرات بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: AppColors.present,
                ));
              }
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.error,
              ));
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('حسابي'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                  onPressed: () => setState(() => _editing = !_editing),
                ),
              ],
            ),
            body: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) return const ShimmerList(itemCount: 6);
                if (state is ProfileError && state is! ProfileLoaded) {
                  return AppErrorWidget(message: state.message, onRetry: () => context.read<ProfileCubit>().loadProfile());
                }
                StudentProfile? profile;
                if (state is ProfileLoaded) profile = state.profile;
                if (state is ProfileUpdating) profile = state.profile;
                if (state is ProfileUpdated) profile = state.profile;
                if (profile == null) return const ShimmerList();

                final isUpdating = state is ProfileUpdating;
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar section
                        Container(
                          width: double.infinity,
                          color: AppColors.primary,
                          padding: const EdgeInsets.only(bottom: 24, top: 16),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _editing ? () => _pickImage(context) : null,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.accent, width: 3),
                                      ),
                                      child: ClipOval(
                                        child: _selectedAvatar != null
                                            ? Image.asset(_selectedAvatar!, fit: BoxFit.cover)
                                            : profile.avatar != null
                                                ? CachedNetworkImage(
                                                    imageUrl: profile.avatar!,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (_, __, ___) => const Icon(Icons.person, size: 50, color: Colors.white70),
                                                  )
                                                : const Icon(Icons.person, size: 50, color: Colors.white70),
                                      ),
                                    ),
                                    if (_editing)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                          child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(profile.name,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text(profile.className,
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white.withOpacity(0.8))),
                            ],
                          ),
                        ),
                        // Editable fields
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (_editing) ...[
                                TextFormField(
                                  controller: _nameCtrl,
                                  validator: (v) => Validators.validateRequired(v, 'الاسم'),
                                  textDirection: TextDirection.rtl,
                                  decoration: const InputDecoration(
                                    labelText: 'الاسم الكامل',
                                    prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                                  ),
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  validator: Validators.validatePhone,
                                  keyboardType: TextInputType.phone,
                                  textDirection: TextDirection.rtl,
                                  decoration: const InputDecoration(
                                    labelText: 'رقم الهاتف',
                                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                                  ),
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isUpdating ? null : () => _save(context),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    child: isUpdating
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('حفظ التغييرات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              // Menu items
                              _MenuItem(icon: Icons.chat_bubble_outline_rounded, label: 'الرسائل', color: AppColors.accent, onTap: () => context.push('/messages')),
                              _MenuItem(icon: Icons.receipt_long_outlined, label: 'عقدي المالي', color: AppColors.accent, onTap: () => context.push('/contract')),
                              _MenuItem(icon: Icons.quiz_outlined, label: 'الاختبارات', color: AppColors.primary, onTap: () => context.push('/exams')),
                              _MenuItem(icon: Icons.folder_outlined, label: 'الملفات', color: AppColors.primary, onTap: () => context.push('/files')),
                              _MenuItem(icon: Icons.calendar_today_outlined, label: 'جدول الحصص', color: AppColors.primary, onTap: () => context.push('/schedule')),
                              _MenuItem(icon: Icons.event_note_outlined, label: 'جداول الامتحانات', color: AppColors.primary, onTap: () => context.push('/exam-schedules')),
                              _MenuItem(icon: Icons.campaign_outlined, label: 'الإعلانات', color: AppColors.primary, onTap: () => context.go('/announcements')),
                              _MenuItem(icon: Icons.notifications_outlined, label: 'الإشعارات', color: AppColors.primary, onTap: () => context.push('/notifications')),
                              _MenuItem(icon: Icons.notes_outlined, label: 'مفكرتي', color: AppColors.primary, onTap: () => context.go('/educational-notes')),
                              const Divider(color: AppColors.divider, height: 24),
                              _MenuItem(
                                icon: Icons.logout_rounded,
                                label: 'تسجيل الخروج',
                                color: AppColors.error,
                                labelColor: AppColors.error,
                                onTap: () => _showLogoutDialog(context),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedAvatar = picked.path);
    }
  }

  void _save(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;
    context.read<ProfileCubit>().updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          avatarPath: _selectedAvatar,
        );
  }

  void _showLogoutDialog(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              authCubit.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor ?? AppColors.textPrimary)),
        trailing: Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
