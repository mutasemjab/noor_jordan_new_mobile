import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_external_link.dart';
import '../cubit/teacher_external_links_cubit.dart';
import '../cubit/teacher_external_links_state.dart';
import 'teacher_external_link_form_page.dart';

class TeacherExternalLinksPage extends StatelessWidget {
  final int classId;
  final String className;

  const TeacherExternalLinksPage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherExternalLinksCubit>(param1: classId)..load(),
      child: _TeacherExternalLinksView(classId: classId, className: className),
    );
  }
}

class _TeacherExternalLinksView extends StatelessWidget {
  final int classId;
  final String className;
  const _TeacherExternalLinksView({required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الروابط الخارجية — $className', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة رابط', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherExternalLinksCubit>(),
              child: TeacherExternalLinkFormPage(classId: classId),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TeacherExternalLinksCubit, TeacherExternalLinksState>(
        builder: (context, state) {
          if (state is TeacherExternalLinksLoading) return const ShimmerList();
          if (state is TeacherExternalLinksError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherExternalLinksCubit>().load());
          }
          if (state is TeacherExternalLinksLoaded) {
            if (state.links.isEmpty) {
              return const EmptyStateWidget(message: 'لا توجد روابط بعد لهذا الصف', icon: Icons.link_off_rounded);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherExternalLinksCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.links.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _LinkCard(link: state.links[i], classId: classId),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final TeacherExternalLink link;
  final int classId;
  const _LinkCard({required this.link, required this.classId});

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TeacherExternalLinksCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الرابط', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذا الرابط؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.delete(link.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherExternalLinksCubit>(),
              child: TeacherExternalLinkFormPage(classId: classId, existingLink: link),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.link_rounded, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (link.subject != null) ...[
                      const SizedBox(height: 3),
                      Text(link.subject!.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
