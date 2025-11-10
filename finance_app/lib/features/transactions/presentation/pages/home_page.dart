import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/core/utils/format.dart';
import 'package:finance_app/features/transactions/presentation/widgets/add_transaction_sheet.dart';
import 'package:finance_app/shared/widgets/empty_state.dart';
import 'package:finance_app/features/transactions/presentation/widgets/transaction_list.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_providers.dart';

class FinanceHomePage extends ConsumerWidget {
  const FinanceHomePage({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state =
          DateTime(picked.year, picked.month, picked.day);
    }
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionSheet(
        date: selectedDate,
        onSave: (item) async {
          final addTransaction = ref.read(addTransactionProvider);
          await addTransaction(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(transactionsForDateProvider);
    final summary = ref.watch(dailySummaryProvider);

    final incomeStr = formatAmount(summary.income);
    final expenseStr = formatAmount(summary.expense);
    final balance = summary.income - summary.expense;
    final balanceStr = formatAmount(balance);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF5A52D5),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '我的钱包',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          onPressed: () => _pickDate(context, ref),
                        ),
                      ],
                    ),
                  ),
                  // Balance Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '今日收入',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          balanceStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                '收入',
                                incomeStr,
                                Icons.arrow_downward,
                                Colors.green[300]!,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                '支出',
                                expenseStr,
                                Icons.arrow_upward,
                                Colors.red[300]!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Date Selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickDate(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            formatDateLong(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Transactions List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '交易记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) => transactions.isEmpty
                    ? const EmptyState()
                    : TransactionList(items: transactions),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        '出错了',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('添加'),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
