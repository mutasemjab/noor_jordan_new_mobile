import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/external_link.dart';
import '../cubit/external_links_cubit.dart';
import '../cubit/external_links_state.dart';

class ExternalLinksPage extends StatelessWidget {
  const ExternalLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExternalLinksCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الروابط الخارجية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ExternalLinksCubit, ExternalLinksState>(
          builder: (context, state) {
            if (state is ExternalLinksLoading) return const ShimmerList();
            if (state is ExternalLinksError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<ExternalLinksCubit>().load());
            }
            if (state is ExternalLinksLoaded) {
              if (state.links.isEmpty) {
                return const EmptyStateWidget(message: 'لا توجد روابط خارجية حالياً', icon: Icons.link_off_rounded);
              }
              final groups = _groupBySubject(state.links);
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<ExternalLinksCubit>().load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _SubjectSection(group: groups[i]),
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

class _SubjectGroup {
  final String subject;
  final List<ExternalLink> links;
  const _SubjectGroup(this.subject, this.links);
}

List<_SubjectGroup> _groupBySubject(List<ExternalLink> links) {
  final map = <String, List<ExternalLink>>{};
  for (final l in links) {
    final key = l.subjectName.isEmpty ? 'أخرى' : l.subjectName;
    map.putIfAbsent(key, () => []).add(l);
  }
  return map.entries.map((e) => _SubjectGroup(e.key, e.value)).toList();
}

class _SubjectSection extends StatelessWidget {
  final _SubjectGroup group;
  const _SubjectSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(group.subject, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ...group.links.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LinkCard(link: l),
              )),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final ExternalLink link;
  const _LinkCard({required this.link});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح الرابط', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.link_rounded, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (link.teacherName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(link.teacherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
