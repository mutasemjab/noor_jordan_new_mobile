import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/trip.dart';
import '../cubit/teacher_trips_cubit.dart';
import '../cubit/teacher_trips_state.dart';
import 'trip_execution_page.dart';

class TeacherTripsPage extends StatelessWidget {
  const TeacherTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherTripsCubit>()..load(),
      child: const _TeacherTripsView(),
    );
  }
}

class _TeacherTripsView extends StatelessWidget {
  const _TeacherTripsView();

  Future<void> _openTrip(BuildContext context, Trip trip) async {
    if (trip.status == TripStatus.notStarted) {
      final cubit = context.read<TeacherTripsCubit>();
      final result = await cubit.start(trip.id);
      if (!context.mounted) return;
      if (result.error != null || result.trip == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'تعذّر بدء الجولة', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TripExecutionPage(trip: result.trip!)),
      );
    } else if (trip.status == TripStatus.inProgress) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TripExecutionPage(trip: trip)),
      );
    }
    if (context.mounted) context.read<TeacherTripsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جولاتي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TeacherTripsCubit, TeacherTripsState>(
        builder: (context, state) {
          if (state is TeacherTripsLoading) return const ShimmerList();
          if (state is TeacherTripsError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherTripsCubit>().load());
          }
          if (state is TeacherTripsLoaded) {
            if (state.trips.isEmpty) {
              return const EmptyStateWidget(message: 'لا توجد جولات اليوم', icon: Icons.directions_bus_outlined);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherTripsCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.trips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TripCard(trip: state.trips[i], onTap: () => _openTrip(context, state.trips[i])),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.onTap});

  Color get _statusColor {
    switch (trip.status) {
      case TripStatus.notStarted:
        return AppColors.textSecondary;
      case TripStatus.inProgress:
        return AppColors.present;
      case TripStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrivedCount = trip.students.where((s) => s.arrivedAt != null).length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: trip.status == TripStatus.completed ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.directions_bus_rounded, color: _statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(trip.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(trip.status.label,
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.w700, color: _statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${trip.type.label} • ${trip.bus.name} • $arrivedCount / ${trip.students.length} طالب',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary)),
                    if (trip.totalDistanceKm != null || trip.totalDurationMinutes != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (trip.totalDistanceKm != null) '${trip.totalDistanceKm!.toStringAsFixed(1)} كم',
                          if (trip.totalDurationMinutes != null) '${trip.totalDurationMinutes} دقيقة',
                        ].join(' • '),
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (trip.status != TripStatus.completed) const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
