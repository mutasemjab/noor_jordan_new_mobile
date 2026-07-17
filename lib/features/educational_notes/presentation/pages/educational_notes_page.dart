import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';

class EducationalNotesPage extends StatelessWidget {
  const EducationalNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotesCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الملاحظات التعليمية'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) return const ShimmerList();
            if (state is NotesError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<NotesCubit>().load());
            }
            if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لا توجد ملاحظات تعليمية',
                  icon: Icons.menu_book_outlined,
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<NotesCubit>().load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notes.length,
                  itemBuilder: (context, index) {
                    final note = state.notes[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + index * 60),
                      builder: (_, v, child) => Opacity(opacity: v, child: child),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  note.createdAt.split('T').first,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 10, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, color: AppColors.textSecondary),
                              ],
                            ),
                            children: [
                              const Divider(color: AppColors.divider),
                              const SizedBox(height: 8),
                              Text(
                                note.body,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    height: 1.7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const ShimmerList();
          },
        ),
      ),
    );
  }
}
