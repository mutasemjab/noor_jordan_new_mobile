import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../../domain/entities/educational_note.dart';
import '../cubit/note_content_cubit.dart';
import '../cubit/note_content_state.dart';

bool _isPdf(String url) => url.toLowerCase().split('?').first.endsWith('.pdf');

void _openAttachment(BuildContext context, String url, String title) {
  if (_isPdf(url)) {
    PdfViewerPage.open(context, url: url, title: title);
  } else {
    FullscreenImageViewer.open(context, url, title: title);
  }
}

class NoteContentPage extends StatelessWidget {
  final DateTime date;
  final NoteSubject subject;
  const NoteContentPage({super.key, required this.date, required this.subject});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return BlocProvider(
      create: (_) => sl<NoteContentCubit>(param1: dateStr, param2: subject.id)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            subject.name,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<NoteContentCubit, NoteContentState>(
          builder: (context, state) {
            if (state is NoteContentLoading) return const ShimmerList();
            if (state is NoteContentError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<NoteContentCubit>().load());
            }
            if (state is NoteContentLoaded) {
              final lessons = state.lessons;
              final homework = state.homework;
              if (lessons.isEmpty && homework.isEmpty) {
                return const EmptyStateWidget(message: 'لا توجد ملاحظات لهذه المادة', icon: Icons.menu_book_outlined);
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (lessons.isNotEmpty) ...[
                    const _SectionTitle(icon: Icons.menu_book_rounded, label: 'الدرس المعطى', color: AppColors.excused),
                    const SizedBox(height: 12),
                    ...lessons.map((n) => _NoteCard(note: n, color: AppColors.excused)),
                    const SizedBox(height: 8),
                  ],
                  if (homework.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const _SectionTitle(icon: Icons.edit_note_rounded, label: 'الواجب', color: AppColors.late),
                    const SizedBox(height: 12),
                    ...homework.map((n) => _NoteCard(note: n, color: AppColors.late)),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteContentItem note;
  final Color color;

  const _NoteCard({required this.note, required this.color});

  @override
  Widget build(BuildContext context) {
    final attachment = note.attachment;
    final hasAttachment = attachment != null && attachment.isNotEmpty;
    final isPdf = hasAttachment && _isPdf(attachment);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 3, color: color),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                if (note.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.description,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7),
                  ),
                ],
                if (hasAttachment) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openAttachment(context, attachment, note.title),
                    child: isPdf
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text('عرض المرفق (PDF)', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                ),
                                const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: attachment,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 160,
                                color: AppColors.divider,
                                child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 160,
                                color: AppColors.divider,
                                child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color.withOpacity(0.12),
                      backgroundImage: note.teacherAvatar != null && note.teacherAvatar!.isNotEmpty
                          ? CachedNetworkImageProvider(note.teacherAvatar!)
                          : null,
                      child: note.teacherAvatar == null || note.teacherAvatar!.isEmpty
                          ? Text(
                              note.teacherName.isNotEmpty ? note.teacherName[0] : '؟',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: color),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        note.className,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
