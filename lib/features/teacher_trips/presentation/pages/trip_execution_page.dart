import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/trip.dart';
import '../cubit/trip_execution_cubit.dart';
import '../cubit/trip_execution_state.dart';

class TripExecutionPage extends StatelessWidget {
  final Trip trip;
  const TripExecutionPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripExecutionCubit>(param1: trip),
      child: const _TripExecutionView(),
    );
  }
}

class _TripExecutionView extends StatelessWidget {
  const _TripExecutionView();

  Future<void> _confirmComplete(BuildContext context) async {
    final cubit = context.read<TripExecutionCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إنهاء الجولة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من إنهاء الجولة؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إنهاء', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.complete();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripExecutionCubit, TripExecutionState>(
      listener: (context, state) {
        if (state is TripExecutionActive && state.toastMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.toastMessage!, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.present),
          );
        }
        if (state is TripExecutionCompleted) {
          Navigator.of(context).pop();
        }
        if (state is TripExecutionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final trip = state is TripExecutionActive ? state.trip : (context.read<TripExecutionCubit>().trip);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(trip.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: state is TripExecutionActive
              ? _ActiveBody(state: state, onComplete: () => _confirmComplete(context))
              : state is TripExecutionError
                  ? _ErrorBody(message: state.message)
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ActiveBody extends StatelessWidget {
  final TripExecutionActive state;
  final VoidCallback onComplete;
  const _ActiveBody({required this.state, required this.onComplete});

  String _formatDistance(int meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} كم';
    return '$meters م';
  }

  @override
  Widget build(BuildContext context) {
    final nextStop = state.nextStop;
    final sorted = [...state.trip.students]..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: nextStop == null
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(18)),
                  child: const Column(
                    children: [
                      Icon(Icons.celebration_rounded, color: Colors.white, size: 36),
                      SizedBox(height: 8),
                      Text('تم الوصول لجميع الطلاب 🎉', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الطالب القادم', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(nextStop.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.social_distance_rounded, size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(_formatDistance(nextStop.distanceMeters), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final error = await context.read<TripExecutionCubit>().markArrivedManually(nextStop.studentId);
                            if (!context.mounted) return;
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                          label: const Text('تعليم كوصل يدوياً', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final student = sorted[i];
              final arrived = state.arrivedStudentIds.contains(student.id);
              final isNext = nextStop?.studentId == student.id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isNext ? AppColors.accent.withOpacity(0.08) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isNext ? AppColors.accent : AppColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(
                      arrived ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: arrived ? AppColors.present : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('${student.stopOrder}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(student.name,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5,
                            fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                            color: arrived ? AppColors.textSecondary : AppColors.textPrimary,
                            decoration: arrived ? TextDecoration.lineThrough : null,
                          )),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: nextStop == null ? AppColors.present : AppColors.surface,
                foregroundColor: nextStop == null ? Colors.white : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: nextStop == null ? Colors.transparent : AppColors.divider)),
              ),
              child: const Text('إنهاء الجولة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }
}
