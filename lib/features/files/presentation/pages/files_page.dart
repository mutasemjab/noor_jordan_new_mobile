import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
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
                  _FileList(files: state.previousExams, emptyMsg: 'لا توجد امتحانات سابقة'),
                  _FileList(files: state.questionBanks, emptyMsg: 'لا يوجد بنك أسئلة'),
                  _FileList(files: state.worksheets, emptyMsg: 'لا توجد أوراق عمل'),
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

class _FileList extends StatelessWidget {
  final List<FileItem> files;
  final String emptyMsg;
  const _FileList({required this.files, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return EmptyStateWidget(message: emptyMsg, icon: Icons.folder_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final file = files[i];
        return Card(
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
                      if (file.subject != null)
                        Text(file.subject!,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                      if (file.year != null)
                        Text('العام ${file.year}',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                  onPressed: () async {
                    final uri = Uri.parse(file.fileUrl);
                    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
