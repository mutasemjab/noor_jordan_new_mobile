import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../domain/entities/educational_note.dart';

class NoteDayDetailPage extends StatelessWidget {
  final DateTime day;
  final List<EducationalNote> notes;

  const NoteDayDetailPage({super.key, required this.day, required this.notes});

  @override
  Widget build(BuildContext context) {
    final lessons = notes.where((n) => n.type == EducationalNoteType.lesson).toList();
    final homework = notes.where((n) => n.type == EducationalNoteType.homework).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          DateFormat('EEEE، d MMMM', 'ar').format(day),
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lessons.isNotEmpty) ...[
            const _SectionTitle(
              icon: Icons.menu_book_rounded,
              label: 'الدرس المعطى',
              color: AppColors.excused,
            ),
            const SizedBox(height: 12),
            ...lessons.map((n) => _NoteCard(note: n, color: AppColors.excused)),
            const SizedBox(height: 8),
          ],
          if (homework.isNotEmpty) ...[
            const SizedBox(height: 12),
            const _SectionTitle(
              icon: Icons.edit_note_rounded,
              label: 'الواجب',
              color: AppColors.late,
            ),
            const SizedBox(height: 12),
            ...homework.map((n) => _NoteCard(note: n, color: AppColors.late)),
          ],
        ],
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
        Text(
          label,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final EducationalNote note;
  final Color color;

  const _NoteCard({required this.note, required this.color});

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (note.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.description,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ],
                if (note.attachment != null && note.attachment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => FullscreenImageViewer.open(context, note.attachment!, title: note.title),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: note.attachment!,
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
