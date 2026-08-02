import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../classes/presentation/cubit/classes_cubit.dart';
import '../../../classes/presentation/cubit/classes_state.dart';
import '../../domain/entities/chat_contact.dart';
import '../../domain/entities/chat_uid.dart';
import 'broadcast_compose_page.dart';
import 'chat_page.dart';

/// Teacher-side entry point for starting a chat: pick a class, then either
/// message one student or broadcast to the whole class.
class TeacherChatContactsPage extends StatelessWidget {
  const TeacherChatContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassesCubit>()..loadClasses(),
      child: const _TeacherChatContactsView(),
    );
  }
}

class _TeacherChatContactsView extends StatelessWidget {
  const _TeacherChatContactsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        final isStudentsView = state is ClassStudentsLoaded || state is ClassStudentsLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: isStudentsView
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.read<ClassesCubit>().loadClasses(),
                  )
                : null,
            title: Text(
              isStudentsView && state is ClassStudentsLoaded
                  ? state.schoolClass.name
                  : 'اختر الصف',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
            ),
            actions: [
              if (state is ClassStudentsLoaded)
                IconButton(
                  icon: const Icon(Icons.campaign_rounded),
                  tooltip: 'بث جماعي للصف',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BroadcastComposePage(
                        classId: state.schoolClass.id,
                        className: state.schoolClass.name,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ClassesState state) {
    if (state is ClassesLoading) return const ShimmerList();
    if (state is ClassesError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<ClassesCubit>().loadClasses(),
      );
    }
    if (state is ClassesLoaded) {
      if (state.classes.isEmpty) {
        return const EmptyStateWidget(message: 'لا توجد صفوف', icon: Icons.class_outlined);
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final cls = state.classes[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.class_rounded, color: AppColors.primary),
              ),
              title: Text(cls.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text('${cls.subject} • ${cls.studentCount} طالب',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
              onTap: () => context.read<ClassesCubit>().loadStudents(cls),
            ),
          );
        },
      );
    }
    if (state is ClassStudentsLoading) return const ShimmerList();
    if (state is ClassStudentsLoaded) {
      final students = state.students;
      if (students.isEmpty) {
        return const EmptyStateWidget(message: 'لا يوجد طلاب بهذا الصف', icon: Icons.people_outline_rounded);
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final student = students[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: student.avatarUrl != null ? CachedNetworkImageProvider(student.avatarUrl!) : null,
                child: student.avatarUrl == null
                    ? Text(student.name.isNotEmpty ? student.name[0] : '؟',
                        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.w700))
                    : null,
              ),
              title: Text(student.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(student.studentNumber, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    contact: ChatContact(
                      id: student.id,
                      uid: ChatUid.student(student.id),
                      name: student.name,
                      avatar: student.avatarUrl,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
