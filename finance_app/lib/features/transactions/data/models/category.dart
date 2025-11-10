import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionCategory {
  final String name;
  final IconData icon;
  final TransactionType type;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.type,
  });
}

// Income Categories
const incomeCategories = [
  TransactionCategory(
    name: '卖水',
    icon: Icons.payments,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: '卖烟',
    icon: Icons.work,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: '卖零食',
    icon: Icons.trending_up,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: '卖面包',
    icon: Icons.card_giftcard,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: '其他收入',
    icon: Icons.attach_money,
    type: TransactionType.income,
  ),
];

// Expense Categories
const expenseCategories = [
  TransactionCategory(
    name: '拿水',
    icon: Icons.restaurant,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: '拿烟',
    icon: Icons.directions_car,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: '拿零食',
    icon: Icons.shopping_bag,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: '拿面包',
    icon: Icons.receipt_long,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: '其他支出',
    icon: Icons.more_horiz,
    type: TransactionType.expense,
  ),
];

// Helper function to get icon for a category name
IconData? getIconForCategory(String categoryName, bool isIncome) {
  final categories = isIncome ? incomeCategories : expenseCategories;
  try {
    return categories.firstWhere((c) => c.name == categoryName).icon;
  } catch (e) {
    return null;
  }
}
