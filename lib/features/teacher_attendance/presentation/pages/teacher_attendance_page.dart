import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/teacher_attendance.dart';
import '../cubit/teacher_attendance_cubit.dart';
import '../cubit/teacher_attendance_state.dart';

class TeacherAttendancePage extends StatelessWidget {
  /// When set, skips the class-picker step and jumps straight into marking
  /// attendance for this class (used when entering via the class hub).
  final TeacherAttendanceClass? initialClass;

  const TeacherAttendancePage({super.key, this.initialClass});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<TeacherAttendanceCubit>();
        final preselected = initialClass;
        if (preselected != null) {
          cubit.selectClass(preselected);
        } else {
          cubit.loadClasses();
        }
        return cubit;
      },
      child: _AttendanceView(initialClass: initialClass),
    );
  }
}

class _AttendanceView extends StatelessWidget {
  final TeacherAttendanceClass? initialClass;
  const _AttendanceView({this.initialClass});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherAttendanceCubit, TeacherAttendanceState>(
      listener: (context, state) {
        if (state is TeacherAttendanceSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الغياب بنجاح', style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.green,
            ),
          );
          if (initialClass != null) {
            // Entered directly from the class hub — go back there instead of
            // dropping into a full class picker that was never fetched.
            Navigator.of(context).maybePop();
          } else {
            context.read<TeacherAttendanceCubit>().loadClasses();
          }
        }
        if (state is TeacherAttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('تسجيل الغياب'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: _buildBody(context, state),
          floatingActionButton: state is TeacherAttendanceStudentsLoaded
              ? FloatingActionButton.extended(
                  onPressed: () => context.read<TeacherAttendanceCubit>().submit(),
                  backgroundColor: AppColors.primary,
                  label: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TeacherAttendanceState state) {
    if (state is TeacherAttendanceLoading || state is TeacherAttendanceSubmitting) {
      return const ShimmerList();
    }

    if (state is TeacherAttendanceError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<TeacherAttendanceCubit>().loadClasses(),
      );
    }

    if (state is TeacherAttendanceClassesLoaded) {
      return _ClassSelector(classes: state.classes);
    }

    if (state is TeacherAttendanceStudentsLoaded) {
      return _StudentAttendanceList(state: state);
    }

    return const ShimmerList();
  }
}

class _ClassSelector extends StatelessWidget {
  final List<TeacherAttendanceClass> classes;
  const _ClassSelector({required this.classes});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const EmptyStateWidget(message: 'لا توجد فصول', icon: Icons.class_outlined);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('اختر الفصل', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: classes.length,
            itemBuilder: (_, i) {
              final cls = classes[i];
              return GestureDetector(
                onTap: () => context.read<TeacherAttendanceCubit>().selectClass(cls),
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
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
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
          ),
        ),
      ],
    );
  }
}

class _StudentAttendanceList extends StatelessWidget {
  final TeacherAttendanceStudentsLoaded state;
  const _StudentAttendanceList({required this.state});

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present: return Colors.green;
      case AttendanceStatus.absent: return Colors.red;
      case AttendanceStatus.late: return Colors.orange;
      case AttendanceStatus.excused: return Colors.blue;
    }
  }

  String _statusLabel(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present: return 'حاضر';
      case AttendanceStatus.absent: return 'غائب';
      case AttendanceStatus.late: return 'متأخر';
      case AttendanceStatus.excused: return 'معذور';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AttendanceStatus.values.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      for (final e in state.entries) {
                        context.read<TeacherAttendanceCubit>().updateStatus(e.studentId, s);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _statusColor(s).withOpacity(0.15),
                      foregroundColor: _statusColor(s),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('الكل ${_statusLabel(s)}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Expanded(
          child: state.entries.isEmpty
              ? const EmptyStateWidget(message: 'لا يوجد طلاب', icon: Icons.people_outline_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.entries.length,
                  itemBuilder: (_, i) {
                    final entry = state.entries[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: entry.avatarUrl != null
                                ? CachedNetworkImageProvider(entry.avatarUrl!)
                                : null,
                            child: entry.avatarUrl == null
                                ? Text(entry.studentName.isNotEmpty ? entry.studentName[0] : '?',
                                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.primary))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(entry.studentName,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ),
                          Wrap(
                            spacing: 4,
                            children: AttendanceStatus.values.map((s) {
                              final isSelected = entry.status == s;
                              return GestureDetector(
                                onTap: () => context.read<TeacherAttendanceCubit>().updateStatus(entry.studentId, s),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _statusColor(s) : _statusColor(s).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSelected ? _statusColor(s) : _statusColor(s).withOpacity(0.3)),
                                  ),
                                  child: Text(_statusLabel(s),
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : _statusColor(s))),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
