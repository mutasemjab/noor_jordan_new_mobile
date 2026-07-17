import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/announcements_cubit.dart';
import '../cubit/announcements_state.dart';
import '../../domain/entities/announcement.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final int id;
  final bool isTeacher;

  const AnnouncementDetailPage({super.key, required this.id, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<AnnouncementsCubit>();
        // Load single item — reuse the list approach: load all and find
        cubit.loadAnnouncements(isTeacher: isTeacher);
        return cubit;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تفاصيل الإعلان'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
          builder: (context, state) {
            if (state is AnnouncementsLoading) return const LoadingOverlay();
            if (state is AnnouncementsError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<AnnouncementsCubit>().loadAnnouncements(isTeacher: isTeacher),
              );
            }
            if (state is AnnouncementsLoaded) {
              Announcement? item;
              try {
                item = state.items.firstWhere((a) => a.id == id);
              } catch (_) {
                item = state.items.isNotEmpty ? state.items.first : null;
              }
              if (item == null) {
                return const Center(child: Text('الإعلان غير موجود', style: TextStyle(fontFamily: 'Cairo')));
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imageUrl != null)
                      Hero(
                        tag: 'announcement-${item.id}',
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(item.publishedAt,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),
                          SelectableText(
                            item.body,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                height: 1.8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const LoadingOverlay();
          },
        ),
      ),
    );
  }
}
