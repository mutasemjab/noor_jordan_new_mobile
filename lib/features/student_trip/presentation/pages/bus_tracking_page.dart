import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/student_trip.dart';
import '../cubit/student_trip_cubit.dart';
import '../cubit/student_trip_state.dart';

class BusTrackingPage extends StatelessWidget {
  const BusTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentTripCubit>()..startPolling(),
      child: const _BusTrackingView(),
    );
  }
}

class _BusTrackingView extends StatelessWidget {
  const _BusTrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تتبع الباص', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StudentTripCubit, StudentTripState>(
        builder: (context, state) {
          if (state is StudentTripLoading) return const ShimmerList();
          if (state is StudentTripError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<StudentTripCubit>().load());
          }
          if (state is StudentTripLoaded) {
            if (state.trip == null) {
              return const EmptyStateWidget(message: 'لا توجد جولة نشطة حالياً', icon: Icons.directions_bus_outlined);
            }
            return _TripStatusCard(trip: state.trip!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TripStatusCard extends StatefulWidget {
  final StudentTrip trip;
  const _TripStatusCard({required this.trip});

  @override
  State<_TripStatusCard> createState() => _TripStatusCardState();
}

class _TripStatusCardState extends State<_TripStatusCard> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    // Re-render every few seconds so the "آخر تحديث قبل..." label stays
    // fresh between the cubit's own 25s polling ticks.
    _tickTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  String _relativeUpdate(DateTime updatedAt) {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inSeconds < 60) return 'قبل ${diff.inSeconds} ثانية';
    return 'قبل ${diff.inMinutes} دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final arrived = trip.arrivedAtMe != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: arrived ? null : AppColors.heroGradient,
          color: arrived ? AppColors.present.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(20),
          border: arrived ? Border.all(color: AppColors.present.withOpacity(0.3)) : null,
        ),
        child: Column(
          children: [
            Icon(
              arrived ? Icons.check_circle_rounded : Icons.directions_bus_rounded,
              color: arrived ? AppColors.present : Colors.white,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              arrived ? 'الباص وصل عندك' : 'الباص بالطريق',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: arrived ? AppColors.present : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trip.busName,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: arrived ? AppColors.textSecondary : Colors.white70),
            ),
            if (!arrived) ...[
              const SizedBox(height: 20),
              if (trip.myEtaMinutes != null)
                _InfoRow(icon: Icons.timer_outlined, label: 'الوقت المتوقع', value: '${trip.myEtaMinutes} دقيقة تقريباً', light: true),
              if (trip.busLocation != null) ...[
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.update_rounded, label: 'آخر تحديث', value: _relativeUpdate(trip.busLocation!.updatedAt), light: true),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool light;
  const _InfoRow({required this.icon, required this.label, required this.value, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppColors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: light ? Colors.white70 : AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: light ? Colors.white70 : AppColors.textSecondary)),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
