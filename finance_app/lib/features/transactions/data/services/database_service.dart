import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'finance_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        is_income INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        time_hour INTEGER NOT NULL,
        time_minute INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create index for faster date queries
    await db.execute('''
      CREATE INDEX idx_transactions_date ON transactions(date)
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
