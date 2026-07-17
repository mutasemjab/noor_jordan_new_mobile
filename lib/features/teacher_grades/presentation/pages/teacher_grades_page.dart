import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_grades.dart';
import '../cubit/teacher_grades_cubit.dart';
import '../cubit/teacher_grades_state.dart';

class TeacherGradesPage extends StatelessWidget {
  const TeacherGradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherGradesCubit>()..loadClasses(),
      child: const _GradesView(),
    );
  }
}

class _GradesView extends StatelessWidget {
  const _GradesView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherGradesCubit, TeacherGradesState>(
      listener: (context, state) {
        if (state is TeacherGradesSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الدرجات بنجاح', style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.green,
            ),
          );
          context.read<TeacherGradesCubit>().loadClasses();
        }
        if (state is TeacherGradesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        String title = 'رصد الدرجات';
        if (state is TeacherGradesExamTypesLoaded) title = state.selectedClass.className;
        if (state is TeacherGradesStudentsLoaded) title = state.selectedExamType.name;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: (state is TeacherGradesExamTypesLoaded || state is TeacherGradesStudentsLoaded)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      if (state is TeacherGradesStudentsLoaded) {
                        context.read<TeacherGradesCubit>().backToExamTypes();
                      } else {
                        context.read<TeacherGradesCubit>().backToClasses();
                      }
                    },
                  )
                : null,
          ),
          body: _buildBody(context, state),
          floatingActionButton: state is TeacherGradesStudentsLoaded
              ? FloatingActionButton.extended(
                  onPressed: () => context.read<TeacherGradesCubit>().submit(),
                  backgroundColor: AppColors.primary,
                  label: const Text('حفظ الدرجات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TeacherGradesState state) {
    if (state is TeacherGradesLoading || state is TeacherGradesSubmitting) return const ShimmerList();
    if (state is TeacherGradesError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<TeacherGradesCubit>().loadClasses(),
      );
    }
    if (state is TeacherGradesClassesLoaded) return _ClassList(classes: state.classes);
    if (state is TeacherGradesExamTypesLoaded) return _ExamTypeList(state: state);
    if (state is TeacherGradesStudentsLoaded) return _StudentGradeList(state: state);
    return const ShimmerList();
  }
}

class _ClassList extends StatelessWidget {
  final List<GradeClass> classes;
  const _ClassList({required this.classes});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) return const EmptyStateWidget(message: 'لا توجد فصول', icon: Icons.class_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (_, i) {
        final cls = classes[i];
        return GestureDetector(
          onTap: () => context.read<TeacherGradesCubit>().selectClass(cls),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls.className, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(cls.subject, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExamTypeList extends StatelessWidget {
  final TeacherGradesExamTypesLoaded state;
  const _ExamTypeList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.examTypes.isEmpty) return const EmptyStateWidget(message: 'لا توجد أنواع اختبارات', icon: Icons.quiz_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.examTypes.length,
      itemBuilder: (_, i) {
        final exam = state.examTypes[i];
        return GestureDetector(
          onTap: () => context.read<TeacherGradesCubit>().selectExamType(exam),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.quiz_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('الدرجة الكاملة: ${exam.maxScore}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentGradeList extends StatelessWidget {
  final TeacherGradesStudentsLoaded state;
  const _StudentGradeList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.entries.isEmpty) return const EmptyStateWidget(message: 'لا يوجد طلاب', icon: Icons.people_outline_rounded);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.entries.length,
      itemBuilder: (_, i) {
        final entry = state.entries[i];
        return _GradeInputCard(
          entry: entry,
          maxScore: state.selectedExamType.maxScore,
          onChanged: (v) => context.read<TeacherGradesCubit>().updateScore(entry.studentId, v),
        );
      },
    );
  }
}

class _GradeInputCard extends StatefulWidget {
  final StudentGradeEntry entry;
  final double maxScore;
  final ValueChanged<double?> onChanged;

  const _GradeInputCard({required this.entry, required this.maxScore, required this.onChanged});

  @override
  State<_GradeInputCard> createState() => _GradeInputCardState();
}

class _GradeInputCardState extends State<_GradeInputCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.entry.score?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.entry.studentName.isNotEmpty ? widget.entry.studentName[0] : '?',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.entry.studentName,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d == null || d < 0 || d > widget.maxScore) return;
                widget.onChanged(d);
              },
              decoration: InputDecoration(
                hintText: '/ ${widget.maxScore.toStringAsFixed(0)}',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
              ),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
