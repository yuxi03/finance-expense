import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/models/category.dart';
import 'package:finance_app/utils/format.dart';
import 'package:finance_app/widgets/edit_transaction_sheet.dart';
import 'package:finance_app/providers/transaction_providers.dart';

class TransactionList extends ConsumerWidget {
  final List<TransactionItem> items;
  const TransactionList({super.key, required this.items});

  void _showEditSheet(BuildContext context, WidgetRef ref, TransactionItem transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTransactionSheet(
        transaction: transaction,
        onSave: (updatedTransaction) async {
          final updateTransaction = ref.read(updateTransactionProvider);
          await updateTransaction(updatedTransaction);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, TransactionItem transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除'),
        content: Text('确定要删除这笔交易吗？\n\n${transaction.category}\n${formatAmount(transaction.amount)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('取消', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final deleteTransaction = ref.read(deleteTransactionProvider);
              await deleteTransaction(transaction.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('交易已删除'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final t = items[index];
        final color = t.isIncome ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
        final categoryIcon = getIconForCategory(t.category, t.isIncome);
        final icon = categoryIcon ?? (t.isIncome ? Icons.arrow_downward : Icons.arrow_upward);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(t.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              // Don't actually dismiss, just show the background
              return false;
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: Colors.red[400], size: 28),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, color: Colors.blue[400], size: 28),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Action buttons (behind the card)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _showEditSheet(context, ref, t),
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(0),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  '编辑',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(context, ref, t),
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(16),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.white, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  '删除',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main card content
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Swipe left to reveal actions
                    if (details.primaryVelocity! < -500) {
                      // Quick swipe left - could add animation here
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showEditSheet(context, ref, t),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon Container
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Transaction Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.category,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${t.time.hour.toString().padLeft(2, '0')}:${t.time.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (t.note != null) ...[
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              t.note!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${t.isIncome ? '+' : '-'}${formatAmount(t.amount).replaceAll('\$', '').replaceFirst('-', '')}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    t.isIncome ? '收入' : '支出',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
