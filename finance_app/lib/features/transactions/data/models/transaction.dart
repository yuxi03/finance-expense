import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final DateTime date;
  final double amount;
  final bool isIncome;
  final String category;
  final String? note;
  final TimeOfDay time;

  const TransactionItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.category,
    this.note,
    required this.time,
  });
}

