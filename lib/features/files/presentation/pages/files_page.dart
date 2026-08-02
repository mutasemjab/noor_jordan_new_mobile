import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../cubit/files_cubit.dart';
import '../cubit/files_state.dart';
import '../../domain/entities/file_item.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FilesCubit>()..loadAll(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الملفات'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabCtrl,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'امتحانات سابقة'),
              Tab(text: 'بنك الأسئلة'),
              Tab(text: 'أوراق العمل'),
            ],
          ),
        ),
        body: BlocBuilder<FilesCubit, FilesState>(
          builder: (context, state) {
            if (state is FilesLoading) return const ShimmerList();
            if (state is FilesError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<FilesCubit>().loadAll());
            }
            if (state is FilesLoaded) {
              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _SubjectsTab(files: state.previousExams, emptyMsg: 'لا توجد امتحانات سابقة'),
                  _SubjectsTab(files: state.questionBanks, emptyMsg: 'لا يوجد بنك أسئلة'),
                  _SubjectsTab(files: state.worksheets, emptyMsg: 'لا توجد أوراق عمل'),
                ],
              );
            }
            return const ShimmerList();
          },
        ),
      ),
    );
  }
}

class _SubjectGroup {
  final String subject;
  final List<FileItem> files;
  const _SubjectGroup(this.subject, this.files);
}

List<_SubjectGroup> _groupBySubject(List<FileItem> files) {
  final map = <String, List<FileItem>>{};
  for (final f in files) {
    final key = (f.subject == null || f.subject!.isEmpty) ? 'أخرى' : f.subject!;
    map.putIfAbsent(key, () => []).add(f);
  }
  final groups = map.entries.map((e) => _SubjectGroup(e.key, e.value)).toList();
  groups.sort((a, b) => a.subject.compareTo(b.subject));
  return groups;
}

/// Subjects-first list — tapping a subject drills into its files for this
/// file kind, rather than showing every file (with its subject as a label)
/// in one flat list.
class _SubjectsTab extends StatelessWidget {
  final List<FileItem> files;
  final String emptyMsg;
  const _SubjectsTab({required this.files, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return EmptyStateWidget(message: emptyMsg, icon: Icons.folder_outlined);
    final groups = _groupBySubject(files);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _SubjectCard(group: groups[i]),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final _SubjectGroup group;
  const _SubjectCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _SubjectFilesPage(group: group)),
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
              const SizedBox(width: 14),
              Expanded(
                child: Text(group.subject,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              Text('${group.files.length} ملف', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectFilesPage extends StatelessWidget {
  final _SubjectGroup group;
  const _SubjectFilesPage({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(group.subject, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: group.files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _FileCard(file: group.files[i]),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final FileItem file;
  const _FileCard({required this.file});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => PdfViewerPage.open(context, url: file.fileUrl, title: file.title),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.title,
                        style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (file.year != null)
                      Text('العام ${file.year}',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
