import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';
import '../cubit/teacher_notes_cubit.dart';
import '../cubit/teacher_notes_state.dart';
import 'teacher_note_form_page.dart';

class TeacherNotesPage extends StatelessWidget {
  final int classId;
  final String className;

  const TeacherNotesPage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherNotesCubit>(param1: classId)..load(),
      child: _TeacherNotesView(classId: classId, className: className),
    );
  }
}

class _TeacherNotesView extends StatelessWidget {
  final int classId;
  final String className;
  const _TeacherNotesView({required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('مفكرتي — $className', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherNotesCubit>(),
              child: TeacherNoteFormPage(classId: classId),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TeacherNotesCubit, TeacherNotesState>(
        builder: (context, state) {
          if (state is TeacherNotesLoading) return const ShimmerList();
          if (state is TeacherNotesError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherNotesCubit>().load());
          }
          if (state is TeacherNotesLoaded) {
            if (state.notes.isEmpty) {
              return const EmptyStateWidget(message: 'لا توجد ملاحظات بعد لهذا الصف', icon: Icons.menu_book_outlined);
            }
            final sorted = [...state.notes]..sort((a, b) => b.date.compareTo(a.date));
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherNotesCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _NoteCard(note: sorted[i], classId: classId),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final EducationalNote note;
  final int classId;
  const _NoteCard({required this.note, required this.classId});

  Color get _color => note.type == EducationalNoteType.lesson ? AppColors.excused : AppColors.late;
  String get _typeLabel => note.type == EducationalNoteType.lesson ? 'درس' : 'واجب';

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TeacherNotesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الملاحظة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذه الملاحظة؟', style: TextStyle(fontFamily: 'Cairo')),
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
    final error = await cubit.delete(note.id);
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
              value: context.read<TeacherNotesCubit>(),
              child: TeacherNoteFormPage(classId: classId, existingNote: note),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 3, color: _color),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.attachment != null && note.attachment!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: note.attachment!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(width: 52, height: 52, color: AppColors.divider),
                      ),
                    )
                  else
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(note.type == EducationalNoteType.lesson ? Icons.menu_book_rounded : Icons.edit_note_rounded, color: _color),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text(_typeLabel, style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.w700, color: _color)),
                            ),
                            const SizedBox(width: 6),
                            Text(DateFormat('d MMM yyyy', 'ar').format(note.date),
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        if (note.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(note.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
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
          ],
        ),
      ),
    );
  }
}
