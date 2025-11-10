import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/utils/format.dart';
import 'package:finance_app/widgets/add_transaction_sheet.dart';
import 'package:finance_app/widgets/empty_state.dart';
import 'package:finance_app/widgets/transaction_list.dart';
import 'package:finance_app/providers/transaction_providers.dart';

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '选择日期',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () => _pickDate(context, ref),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '收入: $incomeStr',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '支出: $expenseStr',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择日期',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      formatDateLong(selectedDate),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) => transactions.isEmpty
                  ? const EmptyState()
                  : TransactionList(items: transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加交易',
        onPressed: () => _openAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

