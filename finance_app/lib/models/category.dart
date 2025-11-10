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
    name: 'Salary',
    icon: Icons.payments,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: 'Freelance',
    icon: Icons.work,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: 'Investment',
    icon: Icons.trending_up,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: 'Gift',
    icon: Icons.card_giftcard,
    type: TransactionType.income,
  ),
  TransactionCategory(
    name: 'Other Income',
    icon: Icons.attach_money,
    type: TransactionType.income,
  ),
];

// Expense Categories
const expenseCategories = [
  TransactionCategory(
    name: 'Food & Dining',
    icon: Icons.restaurant,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Transportation',
    icon: Icons.directions_car,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Shopping',
    icon: Icons.shopping_bag,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Bills & Utilities',
    icon: Icons.receipt_long,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Entertainment',
    icon: Icons.movie,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Healthcare',
    icon: Icons.local_hospital,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Education',
    icon: Icons.school,
    type: TransactionType.expense,
  ),
  TransactionCategory(
    name: 'Other Expense',
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
