import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/services/database_service.dart';
import 'package:finance_app/repositories/transaction_repository.dart';
import 'package:finance_app/models/transaction.dart';

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Transaction repository provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return TransactionRepository(dbService);
});

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Transactions for selected date provider
final transactionsForDateProvider = FutureProvider<List<TransactionItem>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return await repository.getTransactionsForDate(selectedDate);
});

// Daily summary provider (income and expense totals)
final dailySummaryProvider = Provider<({double income, double expense})>((ref) {
  final transactionsAsync = ref.watch(transactionsForDateProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final income = transactions
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => !t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);
      return (income: income, expense: expense);
    },
    loading: () => (income: 0.0, expense: 0.0),
    error: (_, __) => (income: 0.0, expense: 0.0),
  );
});

// Provider to add a transaction
final addTransactionProvider = Provider<Future<void> Function(TransactionItem)>((ref) {
  return (transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.insertTransaction(transaction);
    // Invalidate the transactions list to trigger a refresh
    ref.invalidate(transactionsForDateProvider);
  };
});

// Provider to update a transaction
final updateTransactionProvider = Provider<Future<void> Function(TransactionItem)>((ref) {
  return (transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.updateTransaction(transaction);
    // Invalidate the transactions list to trigger a refresh
    ref.invalidate(transactionsForDateProvider);
  };
});

// Provider to delete a transaction
final deleteTransactionProvider = Provider<Future<void> Function(String)>((ref) {
  return (id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteTransaction(id);
    // Invalidate the transactions list to trigger a refresh
    ref.invalidate(transactionsForDateProvider);
  };
});
