import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/teacher_contacts_cubit.dart';
import '../cubit/teacher_contacts_state.dart';
import 'chat_page.dart';

/// Student-side entry point for starting a chat: the list of teachers who
/// actually teach this student (scoped server-side), tap to open a chat.
class StudentTeacherListPage extends StatelessWidget {
  const StudentTeacherListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherContactsCubit>()..load(),
      child: const _StudentTeacherListView(),
    );
  }
}

class _StudentTeacherListView extends StatelessWidget {
  const _StudentTeacherListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'معلميّ',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TeacherContactsCubit, TeacherContactsState>(
        builder: (context, state) {
          if (state is TeacherContactsLoading) return const ShimmerList();
          if (state is TeacherContactsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<TeacherContactsCubit>().load(),
            );
          }
          if (state is TeacherContactsLoaded) {
            if (state.teachers.isEmpty) {
              return const EmptyStateWidget(
                message: 'لا يوجد معلمون مرتبطون بصفك حالياً',
                icon: Icons.school_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.teachers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final teacher = state.teachers[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: teacher.avatar != null && teacher.avatar!.isNotEmpty
                          ? CachedNetworkImageProvider(teacher.avatar!)
                          : null,
                      child: teacher.avatar == null || teacher.avatar!.isEmpty
                          ? Text(
                              teacher.name.isNotEmpty ? teacher.name[0] : '؟',
                              style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    title: Text(teacher.name,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: teacher.subtitle != null
                        ? Text(teacher.subtitle!,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary))
                        : null,
                    trailing: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatPage(contact: teacher)),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
