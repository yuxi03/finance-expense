import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/utils/format.dart';
import 'package:flutter/material.dart';

class TransactionStore {
  final Map<String, List<TransactionItem>> _byDate = {};

  List<TransactionItem> forDate(DateTime date) =>
      List.unmodifiable(_byDate[dateKey(date)] ?? const []);

  void add(TransactionItem item) {
    final key = dateKey(item.date);
    final list = List<TransactionItem>.from(_byDate[key] ?? const []);
    list.add(item);
    _byDate[key] = list;
  }

  void seedForDate(DateTime date) {
    final key = dateKey(date);
    if (_byDate.containsKey(key)) return;
    _byDate[key] = [
      TransactionItem(
        id: 't1',
        date: date,
        amount: 1200.0,
        isIncome: true,
        category: 'Salary',
        note: 'Monthly payout',
        time: TimeOfDay.now(),
      ),
      TransactionItem(
        id: 't2',
        date: date,
        amount: 18.5,
        isIncome: false,
        category: 'Lunch',
        note: 'Sandwich + coffee',
        time: TimeOfDay.now(),
      ),
    ];
  }
}

