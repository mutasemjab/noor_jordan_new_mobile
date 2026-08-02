import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/subject_video.dart';
import '../../domain/usecases/get_subject_videos_usecase.dart';
import '../cubit/subjects_cubit.dart';
import '../cubit/subjects_state.dart';

class SubjectVideosPage extends StatelessWidget {
  final Subject subject;

  const SubjectVideosPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideosCubit(sl<GetSubjectVideosUseCase>())..loadVideos(subject.id),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            subject.nameAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: BlocBuilder<VideosCubit, VideosState>(
          builder: (context, state) {
            if (state is VideosLoading) {
              return const ShimmerList(itemCount: 5, itemHeight: 100);
            }
            if (state is VideosError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<VideosCubit>().loadVideos(subject.id),
              );
            }
            if (state is VideosLoaded) {
              if (state.videos.isEmpty) {
                return const EmptyStateWidget(
                  message: 'لا توجد فيديوهات لهذه المادة',
                  icon: Icons.video_library_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.videos.length,
                itemBuilder: (context, index) {
                  final video = state.videos[index];
                  return _VideoListItem(
                    video: video,
                    index: index,
                    onTap: () => context.push('/video-player', extra: video),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _VideoListItem extends StatefulWidget {
  final SubjectVideo video;
  final int index;
  final VoidCallback onTap;

  const _VideoListItem({
    required this.video,
    required this.index,
    required this.onTap,
  });

  @override
  State<_VideoListItem> createState() => _VideoListItemState();
}

class _VideoListItemState extends State<_VideoListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.video.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.divider,
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Center(
                                child: Icon(Icons.play_circle_outline,
                                    color: AppColors.primary, size: 36),
                              ),
                            ),
                          ),
                          // Play overlay
                          Container(
                            color: Colors.black.withOpacity(0.25),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.ondemand_video,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'فيديو ${widget.video.orderIndex}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.arrow_back_ios,
                      size: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
