import 'package:flutter/material.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';
import 'package:finance_app/features/transactions/data/services/database_service.dart';
import 'package:finance_app/core/utils/format.dart';

class TransactionRepository {
  final DatabaseService _dbService;

  TransactionRepository(this._dbService);

  // Insert a new transaction
  Future<void> insertTransaction(TransactionItem transaction) async {
    final db = await _dbService.database;
    await db.insert(
      'transactions',
      {
        'id': transaction.id,
        'date': dateKey(transaction.date),
        'amount': transaction.amount,
        'is_income': transaction.isIncome ? 1 : 0,
        'category': transaction.category,
        'note': transaction.note,
        'time_hour': transaction.time.hour,
        'time_minute': transaction.time.minute,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // Get all transactions for a specific date
  Future<List<TransactionItem>> getTransactionsForDate(DateTime date) async {
    final db = await _dbService.database;
    final dateStr = dateKey(date);

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'time_hour DESC, time_minute DESC',
    );

    return maps.map((map) => _transactionFromMap(map)).toList();
  }

  // Get all transactions
  Future<List<TransactionItem>> getAllTransactions() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC, time_hour DESC, time_minute DESC',
    );

    return maps.map((map) => _transactionFromMap(map)).toList();
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a transaction
  Future<void> updateTransaction(TransactionItem transaction) async {
    final db = await _dbService.database;
    await db.update(
      'transactions',
      {
        'date': dateKey(transaction.date),
        'amount': transaction.amount,
        'is_income': transaction.isIncome ? 1 : 0,
        'category': transaction.category,
        'note': transaction.note,
        'time_hour': transaction.time.hour,
        'time_minute': transaction.time.minute,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Helper method to convert database map to TransactionItem
  TransactionItem _transactionFromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] as String;
    final dateParts = dateStr.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    return TransactionItem(
      id: map['id'] as String,
      date: date,
      amount: map['amount'] as double,
      isIncome: (map['is_income'] as int) == 1,
      category: map['category'] as String,
      note: map['note'] as String?,
      time: TimeOfDay(
        hour: map['time_hour'] as int,
        minute: map['time_minute'] as int,
      ),
    );
  }
}
