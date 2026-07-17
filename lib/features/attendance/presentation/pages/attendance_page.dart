import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/attendance.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceCubit>()..load(),
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'الحضور والغياب',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const ShimmerList(itemCount: 5, itemHeight: 100);
          }
          if (state is AttendanceError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<AttendanceCubit>().load(),
            );
          }
          if (state is AttendanceLoaded) {
            return _AttendanceContent(
              state: state,
              focusedDay: _focusedDay,
              onFocusedDayChanged: (day) =>
                  setState(() => _focusedDay = day),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AttendanceContent extends StatelessWidget {
  final AttendanceLoaded state;
  final DateTime focusedDay;
  final ValueChanged<DateTime> onFocusedDayChanged;

  const _AttendanceContent({
    required this.state,
    required this.focusedDay,
    required this.onFocusedDayChanged,
  });

  Map<DateTime, List<AttendanceRecord>> _buildEventMap() {
    final map = <DateTime, List<AttendanceRecord>>{};
    for (final record in state.data.records) {
      final key = DateTime(record.date.year, record.date.month, record.date.day);
      map.putIfAbsent(key, () => []).add(record);
    }
    return map;
  }

  List<AttendanceRecord> _getEventsForDay(
      Map<DateTime, List<AttendanceRecord>> map, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return map[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventMap = _buildEventMap();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar
          Container(
            color: AppColors.surface,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<AttendanceRecord>(
              locale: 'ar',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                if (state.selectedDate == null) return false;
                return isSameDay(state.selectedDate, day);
              },
              onDaySelected: (selectedDay, newFocusedDay) {
                onFocusedDayChanged(newFocusedDay);
                context.read<AttendanceCubit>().selectDate(selectedDay);
              },
              onPageChanged: onFocusedDayChanged,
              eventLoader: (day) => _getEventsForDay(eventMap, day),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                defaultTextStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textPrimary,
                ),
                weekendTextStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondary,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                markersAlignment: Alignment.bottomCenter,
                markerSize: 0,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events
                          .take(3)
                          .map((e) => Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1),
                                decoration: BoxDecoration(
                                  color: _statusColor(e.status),
                                  shape: BoxShape.circle,
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.primary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                weekendStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Selected day records
          if (state.selectedDate != null &&
              state.recordsForSelectedDate.isNotEmpty)
            _SelectedDayRecords(records: state.recordsForSelectedDate),

          if (state.selectedDate != null &&
              state.recordsForSelectedDate.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline,
                        color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'لا توجد سجلات لهذا اليوم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Summary section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'ملخص الحضور',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _SummaryCards(summary: state.data.summary),
                const SizedBox(height: 16),
                // Percentage display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF2d4d99)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'نسبة الحضور',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.data.summary.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Donut chart
                _AttendanceDonutChart(summary: state.data.summary),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.present;
      case AttendanceStatus.absent:
        return AppColors.absent;
      case AttendanceStatus.late:
        return AppColors.late;
      case AttendanceStatus.excused:
        return AppColors.excused;
    }
  }
}

class _SelectedDayRecords extends StatelessWidget {
  final List<AttendanceRecord> records;

  const _SelectedDayRecords({required this.records});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                'سجلات اليوم المحدد',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            ...records.map((record) => _RecordRow(record: record)),
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final AttendanceRecord record;

  const _RecordRow({required this.record});

  Color get _color {
    switch (record.status) {
      case AttendanceStatus.present:
        return AppColors.present;
      case AttendanceStatus.absent:
        return AppColors.absent;
      case AttendanceStatus.late:
        return AppColors.late;
      case AttendanceStatus.excused:
        return AppColors.excused;
    }
  }

  String get _statusLabel {
    switch (record.status) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.excused:
        return 'بعذر';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          if (record.period != null) ...[
            Text(
              'حصة ${record.period}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: record.notes != null && record.notes!.isNotEmpty
                ? Text(
                    record.notes!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final AttendanceSummary summary;

  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'حاضر',
            count: summary.present,
            color: AppColors.present,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'غائب',
            count: summary.absent,
            color: AppColors.absent,
            icon: Icons.cancel_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'متأخر',
            count: summary.late,
            color: AppColors.late,
            icon: Icons.access_time_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'بعذر',
            count: summary.excused,
            color: AppColors.excused,
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDonutChart extends StatefulWidget {
  final AttendanceSummary summary;

  const _AttendanceDonutChart({required this.summary});

  @override
  State<_AttendanceDonutChart> createState() => _AttendanceDonutChartState();
}

class _AttendanceDonutChartState extends State<_AttendanceDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.summary.present +
        widget.summary.absent +
        widget.summary.late +
        widget.summary.excused;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final sections = <PieChartSectionData>[
      _buildSection(
        value: widget.summary.present.toDouble(),
        color: AppColors.present,
        title: 'حاضر',
        index: 0,
      ),
      _buildSection(
        value: widget.summary.absent.toDouble(),
        color: AppColors.absent,
        title: 'غائب',
        index: 1,
      ),
      _buildSection(
        value: widget.summary.late.toDouble(),
        color: AppColors.late,
        title: 'متأخر',
        index: 2,
      ),
      _buildSection(
        value: widget.summary.excused.toDouble(),
        color: AppColors.excused,
        title: 'بعذر',
        index: 3,
      ),
    ].where((s) => s.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Text(
            'توزيع الحضور',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback:
                          (FlTouchEvent event, PieTouchResponse? response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = response
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: sections,
                    centerSpaceRadius: 65,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.summary.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'نسبة الحضور',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(total),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection({
    required double value,
    required Color color,
    required String title,
    required int index,
  }) {
    final isTouched = _touchedIndex == index;
    return PieChartSectionData(
      value: value,
      color: color,
      radius: isTouched ? 36 : 28,
      showTitle: false,
    );
  }

  Widget _buildLegend(int total) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(
            color: AppColors.present,
            label: 'حاضر',
            count: widget.summary.present),
        _LegendItem(
            color: AppColors.absent,
            label: 'غائب',
            count: widget.summary.absent),
        _LegendItem(
            color: AppColors.late,
            label: 'متأخر',
            count: widget.summary.late),
        _LegendItem(
            color: AppColors.excused,
            label: 'بعذر',
            count: widget.summary.excused),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
