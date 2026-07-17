import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_profile.dart';
import '../cubit/teacher_profile_cubit.dart';
import '../cubit/teacher_profile_state.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherProfileCubit>()..loadProfile(),
      child: const _TeacherProfileView(),
    );
  }
}

class _TeacherProfileView extends StatefulWidget {
  const _TeacherProfileView();

  @override
  State<_TeacherProfileView> createState() => _TeacherProfileViewState();
}

class _TeacherProfileViewState extends State<_TeacherProfileView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _avatarPath;
  bool _editMode = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populate(TeacherProfile profile) {
    _nameCtrl.text = profile.name;
    _phoneCtrl.text = profile.phone;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _avatarPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherProfileCubit, TeacherProfileState>(
      listener: (context, state) {
        if (state is TeacherProfileLoaded || state is TeacherProfileUpdated) {
          final p = state is TeacherProfileLoaded ? state.profile : (state as TeacherProfileUpdated).profile;
          _populate(p);
          if (state is TeacherProfileUpdated) {
            setState(() => _editMode = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الملف الشخصي', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.green),
            );
          }
        }
        if (state is TeacherProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('ملفي الشخصي'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              if (state is TeacherProfileLoaded || state is TeacherProfileUpdated)
                TextButton(
                  onPressed: () {
                    if (_editMode) {
                      context.read<TeacherProfileCubit>().updateProfile(
                        name: _nameCtrl.text.trim(),
                        phone: _phoneCtrl.text.trim(),
                        avatarPath: _avatarPath,
                      );
                    } else {
                      setState(() => _editMode = true);
                    }
                  },
                  child: Text(_editMode ? 'حفظ' : 'تعديل',
                      style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TeacherProfileState state) {
    if (state is TeacherProfileLoading) return const ShimmerList();
    if (state is TeacherProfileError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<TeacherProfileCubit>().loadProfile(),
      );
    }

    TeacherProfile? profile;
    bool isUpdating = false;

    if (state is TeacherProfileLoaded) profile = state.profile;
    if (state is TeacherProfileUpdated) profile = state.profile;
    if (state is TeacherProfileUpdating) {
      profile = state.profile;
      isUpdating = true;
    }

    if (profile == null) return const ShimmerList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
                child: ClipOval(
                  child: _avatarPath != null
                      ? Image.file(File(_avatarPath!), fit: BoxFit.cover)
                      : profile.avatarUrl != null
                          ? CachedNetworkImage(imageUrl: profile.avatarUrl!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                            ),
                ),
              ),
              if (_editMode)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(profile.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(profile.subject, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Info cards
          _InfoCard(label: 'رقم الموظف', value: profile.employeeNumber, icon: Icons.badge_outlined),
          const SizedBox(height: 10),
          _InfoCard(label: 'البريد الإلكتروني', value: profile.email, icon: Icons.email_outlined),
          const SizedBox(height: 10),

          if (_editMode) ...[
            _EditField(label: 'الاسم الكامل', controller: _nameCtrl, icon: Icons.person_outline_rounded),
            const SizedBox(height: 10),
            _EditField(label: 'رقم الهاتف', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          ] else ...[
            _InfoCard(label: 'الاسم الكامل', value: profile.name, icon: Icons.person_outline_rounded),
            const SizedBox(height: 10),
            _InfoCard(label: 'رقم الهاتف', value: profile.phone, icon: Icons.phone_outlined),
          ],

          if (isUpdating) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
          ],

          const SizedBox(height: 32),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),

          // Logout
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            ),
            title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await sl<LocalStorage>().clearAll();
              if (context.mounted) context.go('/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      style: const TextStyle(fontFamily: 'Cairo'),
    );
  }
}
