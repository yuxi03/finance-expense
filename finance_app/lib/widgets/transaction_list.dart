import 'package:flutter/material.dart';
import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/models/category.dart';
import 'package:finance_app/utils/format.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionItem> items;
  const TransactionList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final t = items[index];
        final color = t.isIncome ? Colors.green : Colors.red;
        final categoryIcon = getIconForCategory(t.category, t.isIncome);
        final icon = categoryIcon ?? (t.isIncome ? Icons.arrow_downward : Icons.arrow_upward);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(t.category),
          subtitle: Text(
            t.note ?? (t.isIncome ? 'Income' : 'Expense'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            (t.isIncome ? '+' : '-') + formatAmount(t.amount).replaceFirst('-', ''),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemCount: items.length,
    );
  }
}

