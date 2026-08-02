import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../cubit/contract_cubit.dart';
import '../cubit/contract_state.dart';
import '../../domain/entities/contract.dart';

class ContractPage extends StatelessWidget {
  const ContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContractCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('عقدي المالي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 17)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<ContractCubit, ContractState>(
          builder: (context, state) {
            if (state is ContractLoading) return const ShimmerList(itemCount: 4);
            if (state is ContractError) {
              return AppErrorWidget(message: state.message, onRetry: () => context.read<ContractCubit>().load());
            }
            if (state is ContractLoaded) return _ContractBody(contract: state.contract);
            return const ShimmerList();
          },
        ),
      ),
    );
  }
}

class _ContractBody extends StatelessWidget {
  final Contract contract;
  const _ContractBody({required this.contract});

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('d MMMM yyyy', 'ar').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final paidRatio = contract.totalAmount > 0 ? (contract.paidAmount / contract.totalAmount).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AmountColumn(label: 'الإجمالي', amount: contract.totalAmount, color: Colors.white),
                    Container(width: 1, height: 50, color: Colors.white24),
                    _AmountColumn(label: 'المدفوع', amount: contract.paidAmount, color: AppColors.accent),
                    Container(width: 1, height: 50, color: Colors.white24),
                    _AmountColumn(label: 'المتبقي', amount: contract.remainingAmount, color: const Color(0xFFFF7B7B)),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسبة السداد',
                            style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        Text('${(paidRatio * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontFamily: 'Cairo', color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: paidRatio),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (contract.startDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 8),
                        Text('تاريخ بداية العقد: ${_formatDate(contract.startDate!)}',
                            style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // PDF Button
          if (contract.contractPdfUrl != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => PdfViewerPage.open(context, url: contract.contractPdfUrl!, title: 'وثيقة العقد'),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
                label: const Text('عرض وثيقة العقد',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Payments List
          Row(
            children: [
              const Text('الوصولات',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Text('${contract.payments.length}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contract.payments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Center(
                child: Text('لا توجد وصولات دفع بعد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ...contract.payments.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + i * 70),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(color: AppColors.present.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.present.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_outline, color: AppColors.present, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p.amount.toStringAsFixed(2)} دينار',
                                style: const TextStyle(
                                    fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(_formatDate(p.paidAt),
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                            if (p.notes != null && p.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(p.notes!,
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
                            ],
                          ],
                        ),
                      ),
                      if (p.receiptNumber.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('رقم الوصل', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: AppColors.textSecondary)),
                              Text(p.receiptNumber,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          if (contract.notes != null && contract.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(contract.notes!,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _AmountColumn({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 6),
        Text(amount.toStringAsFixed(0),
            style: TextStyle(fontFamily: 'Cairo', color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text('دينار', style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }
}
