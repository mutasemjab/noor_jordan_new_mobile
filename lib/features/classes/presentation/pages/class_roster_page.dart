import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/school_class.dart';
import '../cubit/classes_cubit.dart';
import '../cubit/classes_state.dart';

/// Standalone roster view for a single class — entered from the class hub.
/// Uses its own fresh [ClassesCubit] instance so it doesn't interfere with
/// the shared one backing the "فصولي" tab's own class list/roster flow.
class ClassRosterPage extends StatelessWidget {
  final SchoolClass schoolClass;
  const ClassRosterPage({super.key, required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClassesCubit>()..loadStudents(schoolClass),
      child: _RosterView(schoolClass: schoolClass),
    );
  }
}

class _RosterView extends StatefulWidget {
  final SchoolClass schoolClass;
  const _RosterView({required this.schoolClass});

  @override
  State<_RosterView> createState() => _RosterViewState();
}

class _RosterViewState extends State<_RosterView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.schoolClass.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => context.read<ClassesCubit>().search(q),
              decoration: InputDecoration(
                hintText: 'ابحث عن طالب...',
                hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ClassesCubit>().search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ClassesCubit, ClassesState>(
              builder: (context, state) {
                if (state is ClassStudentsLoading) return const ShimmerList();
                if (state is ClassStudentsLoaded) {
                  final students = state.filtered;
                  if (students.isEmpty) {
                    return const EmptyStateWidget(message: 'لا يوجد طلاب', icon: Icons.people_outline_rounded);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final student = students[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: student.avatarUrl != null ? CachedNetworkImageProvider(student.avatarUrl!) : null,
                              child: student.avatarUrl == null
                                  ? Text(student.name.isNotEmpty ? student.name[0] : '؟',
                                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppColors.primary))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(student.studentNumber,
                                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
