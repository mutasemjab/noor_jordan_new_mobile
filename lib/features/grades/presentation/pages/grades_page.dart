import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/grade.dart';
import '../cubit/grades_cubit.dart';
import '../cubit/grades_state.dart';

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GradesCubit>()..load(),
      child: const _GradesView(),
    );
  }
}

class _GradesView extends StatelessWidget {
  const _GradesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'علاماتي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<GradesCubit, GradesState>(
        builder: (context, state) {
          if (state is GradesLoading) {
            return const ShimmerList(itemCount: 4, itemHeight: 120);
          }
          if (state is GradesError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<GradesCubit>().load(),
            );
          }
          if (state is GradesLoaded) {
            if (state.grades.isEmpty) {
              return const EmptyStateWidget(
                message: 'لا توجد علامات',
                subMessage: 'لم يتم تسجيل أي علامات حتى الآن',
                icon: Icons.grade_outlined,
              );
            }
            return _GradesContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GradesContent extends StatelessWidget {
  final GradesLoaded state;

  const _GradesContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SubjectFilterChips(state: state),
        Expanded(
          child: state.filteredGrades.isEmpty
              ? const EmptyStateWidget(
                  message: 'لا توجد علامات لهذه المادة',
                  icon: Icons.grade_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.filteredGrades.length,
                  itemBuilder: (context, index) {
                    return _SubjectGradesCard(
                      subject: state.filteredGrades[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SubjectFilterChips extends StatelessWidget {
  final GradesLoaded state;

  const _SubjectFilterChips({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterChip(
              label: 'الكل',
              isSelected: state.selectedFilter == null,
              onTap: () =>
                  context.read<GradesCubit>().filterBySubject(null),
            ),
            ...state.grades.map((subject) {
              final isSelected =
                  state.selectedFilter == subject.subjectId.toString();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: subject.subjectName,
                  isSelected: isSelected,
                  color: _parseColor(subject.colorClass),
                  onTap: () => context
                      .read<GradesCubit>()
                      .filterBySubject(subject.subjectId.toString()),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return null;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? (color ?? AppColors.primary) : AppColors.divider;
    final fg = isSelected ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _SubjectGradesCard extends StatefulWidget {
  final SubjectGrades subject;

  const _SubjectGradesCard({required this.subject});

  @override
  State<_SubjectGradesCard> createState() => _SubjectGradesCardState();
}

class _SubjectGradesCardState extends State<_SubjectGradesCard> {
  bool _expanded = false;

  Color get _subjectColor {
    final hex = widget.subject.colorClass;
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded ? _buildExpandedContent() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Subject icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _subjectColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.subject.subjectIcon != null &&
                        widget.subject.subjectIcon!.isNotEmpty
                    ? Text(
                        widget.subject.subjectIcon!,
                        style: const TextStyle(fontSize: 22),
                      )
                    : Icon(Icons.book_outlined,
                        color: _subjectColor, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject.subjectName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.subject.grades.length} علامة',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Circular progress showing average
            _AverageCircle(
              average: widget.subject.average,
              color: _subjectColor,
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final grades = widget.subject.grades;
    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        // Grade entries
        ...grades.map((grade) => _GradeEntryRow(entry: grade)),
        // Bar chart for last 5 grades
        if (grades.isNotEmpty) ...[
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مسار العلامات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: _GradesBarChart(
                    grades: grades.length > 5
                        ? grades.sublist(grades.length - 5)
                        : grades,
                    color: _subjectColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AverageCircle extends StatelessWidget {
  final double average;
  final Color color;

  const _AverageCircle({required this.average, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (average / 100).clamp(0.0, 1.0),
            strokeWidth: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${average.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeEntryRow extends StatelessWidget {
  final GradeEntry entry;

  const _GradeEntryRow({required this.entry});

  Color _percentageColor(double pct) {
    if (pct >= 90) return const Color(0xFF4CAF50);
    if (pct >= 75) return const Color(0xFF2196F3);
    if (pct >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFd32f2f);
  }

  @override
  Widget build(BuildContext context) {
    final pctColor = _percentageColor(entry.percentage);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(entry.gradedAt),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.score}/${entry.maxScore}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pctColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pctColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _GradesBarChart extends StatelessWidget {
  final List<GradeEntry> grades;
  final Color color;

  const _GradesBarChart({required this.grades, required this.color});

  @override
  Widget build(BuildContext context) {
    final bars = grades.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.percentage.clamp(0, 100),
            color: color,
            width: 20,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: AppColors.divider,
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        barGroups: bars,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= grades.length) {
                  return const SizedBox.shrink();
                }
                final title = grades[idx].title;
                final short = title.length > 6
                    ? title.substring(0, 6)
                    : title;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    short,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
