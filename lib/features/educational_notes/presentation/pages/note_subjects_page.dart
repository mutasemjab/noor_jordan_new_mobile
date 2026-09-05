import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/educational_note.dart';
import '../cubit/note_subjects_cubit.dart';
import '../cubit/note_subjects_state.dart';
import 'note_content_page.dart';

/// Maps the backend's Bootstrap-style hints (`bi-*` icon names, Bootstrap
/// contextual color classes) to Flutter equivalents — best-effort, falls
/// back to a generic subject icon/color for anything unrecognized.
IconData _iconFor(String? icon) {
  final key = (icon ?? '').replaceFirst('bi-', '');
  switch (key) {
    case 'calculator':
      return Icons.calculate_rounded;
    case 'book':
    case 'book-half':
    case 'journal-text':
      return Icons.menu_book_rounded;
    case 'globe':
    case 'globe2':
      return Icons.public_rounded;
    case 'flask':
    case 'flask2':
      return Icons.science_rounded;
    case 'palette':
    case 'palette2':
      return Icons.palette_rounded;
    case 'music-note':
    case 'music-note-beamed':
      return Icons.music_note_rounded;
    case 'laptop':
    case 'pc':
    case 'cpu':
      return Icons.computer_rounded;
    case 'translate':
      return Icons.translate_rounded;
    case 'mosque':
      return Icons.mosque_rounded;
    case 'heart-pulse':
      return Icons.favorite_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

Color _colorFor(String? colorClass) {
  switch (colorClass) {
    case 'primary':
      return AppColors.primary;
    case 'secondary':
      return AppColors.textSecondary;
    case 'success':
      return AppColors.present;
    case 'danger':
      return AppColors.error;
    case 'warning':
      return AppColors.late;
    case 'info':
      return AppColors.accent;
    default:
      return AppColors.primary;
  }
}

class NoteSubjectsPage extends StatelessWidget {
  final DateTime date;
  const NoteSubjectsPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return BlocProvider(
      create: (_) => sl<NoteSubjectsCubit>(param1: dateStr)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            DateFormat('EEEE، d MMMM', 'ar').format(date),
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<NoteSubjectsCubit, NoteSubjectsState>(
          builder: (context, state) {
            if (state is NoteSubjectsLoading) return const ShimmerList(itemCount: 4, itemHeight: 84);
            if (state is NoteSubjectsError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<NoteSubjectsCubit>().load());
            }
            if (state is NoteSubjectsLoaded) {
              if (state.subjects.isEmpty) {
                return const EmptyStateWidget(message: 'لا توجد مواد بهذا اليوم', icon: Icons.menu_book_outlined);
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SubjectCard(
                  subject: state.subjects[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteContentPage(date: date, subject: state.subjects[i]),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final NoteSubject subject;
  final VoidCallback onTap;
  const _SubjectCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(subject.colorClass);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_iconFor(subject.icon), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (subject.lessonsCount > 0)
                          _CountChip(icon: Icons.menu_book_rounded, count: subject.lessonsCount, color: AppColors.excused, label: 'درس'),
                        if (subject.lessonsCount > 0 && subject.homeworkCount > 0) const SizedBox(width: 8),
                        if (subject.homeworkCount > 0)
                          _CountChip(icon: Icons.edit_note_rounded, count: subject.homeworkCount, color: AppColors.late, label: 'واجب'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _CountChip({required this.icon, required this.count, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text('$count $label', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
