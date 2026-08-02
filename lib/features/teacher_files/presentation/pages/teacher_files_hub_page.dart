import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_common/domain/usecases/get_class_subjects_usecase.dart';
import '../../domain/entities/teacher_file_item.dart';
import '../cubit/teacher_files_cubit.dart';
import '../cubit/teacher_files_state.dart';
import 'teacher_file_form_page.dart';

class TeacherFilesHubPage extends StatefulWidget {
  final int classId;
  final String className;

  const TeacherFilesHubPage({super.key, required this.classId, required this.className});

  @override
  State<TeacherFilesHubPage> createState() => _TeacherFilesHubPageState();
}

class _TeacherFilesHubPageState extends State<TeacherFilesHubPage> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  static const _kinds = [TeacherFileKind.previousYearExam, TeacherFileKind.questionBank, TeacherFileKind.worksheet];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _kinds.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الملفات — ${widget.className}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accent,
          tabs: _kinds.map((k) => Tab(text: k.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _kinds.map((kind) => _FileKindSubjectsTab(kind: kind, classId: widget.classId)).toList(),
      ),
    );
  }
}

/// Per-kind tab: lists the subjects taught in this class first — tapping one
/// drills into that subject's files for this kind.
class _FileKindSubjectsTab extends StatefulWidget {
  final TeacherFileKind kind;
  final int classId;
  const _FileKindSubjectsTab({required this.kind, required this.classId});

  @override
  State<_FileKindSubjectsTab> createState() => _FileKindSubjectsTabState();
}

class _FileKindSubjectsTabState extends State<_FileKindSubjectsTab> {
  late final Future<List<TeacherSubject>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<GetClassSubjectsUseCase>()(widget.classId).then(
      (either) => either.fold((f) => throw Exception(f.message), (subjects) => subjects),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeacherSubject>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const ShimmerList();
        if (snapshot.hasError) {
          return AppErrorWidget(message: 'تعذّر تحميل المواد', onRetry: () => setState(() {}));
        }
        final subjects = snapshot.data ?? [];
        if (subjects.isEmpty) {
          return const EmptyStateWidget(message: 'لا توجد مواد مسندة لك بهذا الصف', icon: Icons.menu_book_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _SubjectCard(kind: widget.kind, classId: widget.classId, subject: subjects[i]),
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final TeacherFileKind kind;
  final int classId;
  final TeacherSubject subject;
  const _SubjectCard({required this.kind, required this.classId, required this.subject});

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
          MaterialPageRoute(builder: (_) => _SubjectFilesPage(kind: kind, classId: classId, subject: subject)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(subject.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectFilesPage extends StatelessWidget {
  final TeacherFileKind kind;
  final int classId;
  final TeacherSubject subject;
  const _SubjectFilesPage({required this.kind, required this.classId, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TeacherFilesCubit>(param1: TeacherFilesScope(kind: kind, classId: classId, subjectId: subject.id))..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('${kind.label} — ${subject.name}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
            label: const Text('رفع ملف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Colors.white)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<TeacherFilesCubit>(),
                  child: TeacherFileFormPage(kind: kind, subject: subject),
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<TeacherFilesCubit, TeacherFilesState>(
          builder: (context, state) {
            if (state is TeacherFilesLoading) return const ShimmerList();
            if (state is TeacherFilesError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<TeacherFilesCubit>().load());
            }
            if (state is TeacherFilesLoaded) {
              if (state.files.isEmpty) {
                return const EmptyStateWidget(message: 'لا توجد ملفات بعد', icon: Icons.folder_outlined);
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<TeacherFilesCubit>().load(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _FileCard(file: state.files[i], kind: kind, subject: subject),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final TeacherFileItem file;
  final TeacherFileKind kind;
  final TeacherSubject subject;
  const _FileCard({required this.file, required this.kind, required this.subject});

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TeacherFilesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الملف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من حذف هذا الملف؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.delete(file.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => PdfViewerPage.open(context, url: file.pdfUrl, title: file.title),
        onLongPress: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TeacherFilesCubit>(),
              child: TeacherFileFormPage(kind: kind, subject: subject, existingFile: file),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (file.year != null)
                      Text('العام ${file.year}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TeacherFilesCubit>(),
                      child: TeacherFileFormPage(kind: kind, subject: subject, existingFile: file),
                    ),
                  ),
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
}
