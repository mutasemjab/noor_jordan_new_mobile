import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/educational_note.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import 'note_day_detail_page.dart';

class EducationalNotesPage extends StatelessWidget {
  const EducationalNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotesCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'مفكرتي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading || state is NotesInitial) {
              return const ShimmerList(itemCount: 6, itemHeight: 84);
            }
            if (state is NotesError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<NotesCubit>().load());
            }
            if (state is NotesLoaded) {
              final days = state.days;
              if (days.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لا توجد ملاحظات تعليمية بعد',
                  icon: Icons.menu_book_outlined,
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<NotesCubit>().load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final dayNotes = state.notesForDay(day);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 250 + index * 60),
                      builder: (_, v, child) => Opacity(opacity: v, child: child),
                      child: _DayCard(
                        day: day,
                        notes: dayNotes,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteDayDetailPage(day: day, notes: dayNotes),
                          ),
                        ),
                      ),
                    );
                  },
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

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<EducationalNote> notes;
  final VoidCallback onTap;

  const _DayCard({required this.day, required this.notes, required this.onTap});

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final lessonsCount = notes.where((n) => n.type == EducationalNoteType.lesson).length;
    final homeworkCount = notes.where((n) => n.type == EducationalNoteType.homework).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isToday ? AppColors.primary.withOpacity(0.3) : AppColors.divider),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: _isToday ? AppColors.primaryGradient : null,
                  color: _isToday ? null : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d', 'ar').format(day),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _isToday ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'ar').format(day),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _isToday ? Colors.white70 : AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('EEEE', 'ar').format(day),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'اليوم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (lessonsCount > 0) _CountChip(icon: Icons.menu_book_rounded, count: lessonsCount, color: AppColors.excused, label: 'درس'),
                        if (lessonsCount > 0 && homeworkCount > 0) const SizedBox(width: 8),
                        if (homeworkCount > 0) _CountChip(icon: Icons.edit_note_rounded, count: homeworkCount, color: AppColors.late, label: 'واجب'),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
