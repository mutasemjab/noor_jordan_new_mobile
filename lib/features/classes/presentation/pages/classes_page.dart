import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/classes_cubit.dart';
import '../cubit/classes_state.dart';
import 'class_students_page.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassesCubit>()..loadClasses(),
      child: const _ClassesView(),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassStudentsLoaded || state is ClassStudentsLoading) {
          return ClassStudentsPage(cubit: context.read<ClassesCubit>());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('فصولي'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
        return const EmptyStateWidget(message: 'لا توجد فصول', icon: Icons.class_outlined);
      }
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: state.classes.length,
        itemBuilder: (_, i) {
          final cls = state.classes[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + i * 80),
            builder: (_, v, child) => Opacity(opacity: v, child: child),
            child: GestureDetector(
              onTap: () => context.read<ClassesCubit>().loadStudents(cls),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(cls.name,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(cls.subject,
                        style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${cls.studentCount} طالب',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return const ShimmerList();
  }
}
