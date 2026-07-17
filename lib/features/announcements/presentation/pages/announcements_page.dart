import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/announcements_cubit.dart';
import '../cubit/announcements_state.dart';

class AnnouncementsPage extends StatelessWidget {
  final bool isTeacher;
  const AnnouncementsPage({super.key, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnnouncementsCubit>()..loadAnnouncements(isTeacher: isTeacher),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الإعلانات'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
          builder: (context, state) {
            if (state is AnnouncementsLoading) return const ShimmerList();
            if (state is AnnouncementsError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<AnnouncementsCubit>().loadAnnouncements(isTeacher: isTeacher),
              );
            }
            if (state is AnnouncementsLoaded) {
              if (state.items.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لا توجد إعلانات',
                  icon: Icons.campaign_outlined,
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification && n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    context.read<AnnouncementsCubit>().loadMore();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<AnnouncementsCubit>().loadAnnouncements(isTeacher: isTeacher),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state is AnnouncementsLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ));
                      }
                      final item = state.items[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + index * 50),
                        curve: Curves.easeOut,
                        builder: (_, v, child) => Opacity(opacity: v, child: child),
                        child: GestureDetector(
                          onTap: () => context.push('/announcements/${item.id}'),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.imageUrl != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl!,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text(item.publishedAt,
                                          style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 11,
                                              color: AppColors.textSecondary)),
                                      const SizedBox(height: 8),
                                      Text(item.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                              height: 1.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return const ShimmerList();
          },
        ),
      ),
    );
  }
}
