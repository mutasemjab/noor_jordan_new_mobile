import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
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
          title: const Text('عقدي المالي'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسبة السداد',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12)),
                        Text('${(paidRatio * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          // PDF Button
          if (contract.contractPdfUrl != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(contract.contractPdfUrl!)),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.error),
                label: const Text('عرض الوثيقة',
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
          if (contract.payments.isNotEmpty) ...[
            const Text('سجل المدفوعات',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...contract.payments.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + i * 80),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.present.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, color: AppColors.present, size: 22),
                    ),
                    title: Text(
                      '${p.amount.toStringAsFixed(2)} دينار',
                      style: const TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(p.paymentDate,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    trailing: p.receiptUrl != null
                        ? IconButton(
                            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                            onPressed: () => launchUrl(Uri.parse(p.receiptUrl!)),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ],
          if (contract.notes != null) ...[
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
                        style: const TextStyle(
                            fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                  ),
                ],
              ),
            ),
          ],
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
        Text('${amount.toStringAsFixed(0)}',
            style: TextStyle(fontFamily: 'Cairo', color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text('دينار', style: TextStyle(fontFamily: 'Cairo', color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }
}
