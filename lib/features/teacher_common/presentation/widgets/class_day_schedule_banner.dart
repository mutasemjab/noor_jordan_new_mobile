import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/day_period.dart';
import '../../domain/usecases/get_class_day_schedule_usecase.dart';

/// Read-only info banner showing a class's period schedule for one day —
/// e.g. above the "مفكرتي" note form, so the teacher sees what's taught in
/// that class/day before logging a note. Hides itself entirely when there's
/// no schedule for that day (weekend, not filled in yet) or on any error —
/// it's a convenience hint, not something that should block or alarm.
class ClassDayScheduleBanner extends StatefulWidget {
  final int classId;
  final DateTime date;
  const ClassDayScheduleBanner({super.key, required this.classId, required this.date});

  @override
  State<ClassDayScheduleBanner> createState() => _ClassDayScheduleBannerState();
}

class _ClassDayScheduleBannerState extends State<ClassDayScheduleBanner> {
  late Future<List<ClassDayPeriod>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(ClassDayScheduleBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId || !_isSameDay(oldWidget.date, widget.date)) {
      setState(() => _future = _load());
    }
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<ClassDayPeriod>> _load() {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    return sl<GetClassDayScheduleUseCase>()(classId: widget.classId, date: dateStr).then(
      (either) => either.fold((_) => const <ClassDayPeriod>[], (periods) => periods),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClassDayPeriod>>(
      future: _future,
      builder: (context, snapshot) {
        final periods = snapshot.data ?? const <ClassDayPeriod>[];
        if (periods.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('جدول هذا اليوم لهذا الصف',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ...periods.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${p.label}: ${p.subjectName}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
