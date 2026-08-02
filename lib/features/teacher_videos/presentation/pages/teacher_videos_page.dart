import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/domain/entities/subject_video.dart';
import '../../../subjects/presentation/pages/video_player_page.dart';
import '../../domain/entities/teacher_video.dart';
import '../cubit/teacher_videos_cubit.dart';
import '../cubit/teacher_videos_state.dart';
import 'teacher_video_form_page.dart';

class TeacherVideosPage extends StatelessWidget {
  final int classId;
  final String className;

  const TeacherVideosPage({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherVideosCubit>(param1: classId)..load(),
      child: _TeacherVideosView(classId: classId, className: className),
    );
  }
}

class _TeacherVideosView extends StatelessWidget {
  final int classId;
  final String className;
  const _TeacherVideosView({required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الفيديوهات — $className', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة فيديو', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherVideosCubit>(),
              child: TeacherVideoFormPage(classId: classId),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TeacherVideosCubit, TeacherVideosState>(
        builder: (context, state) {
          if (state is TeacherVideosLoading) return const ShimmerList();
          if (state is TeacherVideosError) {
            return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherVideosCubit>().load());
          }
          if (state is TeacherVideosLoaded) {
            if (state.videos.isEmpty) {
              return const EmptyStateWidget(message: 'لا توجد فيديوهات بعد لهذا الصف', icon: Icons.smart_display_outlined);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TeacherVideosCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.videos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VideoCard(video: state.videos[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final TeacherVideo video;
  const _VideoCard({required this.video});

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TeacherVideosCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الفيديو', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذا الفيديو؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.delete(video.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(
              video: SubjectVideo(
                id: video.id,
                title: video.title,
                youtubeUrl: video.youtubeUrl,
                youtubeId: video.youtubeId,
                thumbnail: '',
                orderIndex: 0,
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: video.youtubeId.isNotEmpty
                    ? Image.network(
                        YoutubePlayer.getThumbnail(videoId: video.youtubeId),
                        width: 60,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackThumb(),
                      )
                    : _fallbackThumb(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (video.subject != null) ...[
                      const SizedBox(height: 3),
                      Text(video.subject!.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      width: 60,
      height: 44,
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.smart_display_rounded, color: AppColors.primary, size: 22),
    );
  }
}
