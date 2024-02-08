import 'globals.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TransactionsDB {
  static Database? _database;

  static const String tableName = 'Transactions';

  static Future<Database> getDatabase(int userId) async {
    if (_database != null) return _database!;
    _database = await initDatabase(userId);
    return _database!;
  }

  static Future<Database> initDatabase(int userId) async {
    String databasePath = "lib/DB/transactions_$userId.db";
    String path = join(await getDatabasesPath(), databasePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            transactionID INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionType TEXT,
            recurring INTEGER,
            dateTime TEXT,
            category TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertTransaction(Transaction transaction) async {
    final Database db = await getDatabase(getUserID());
    await db.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Transaction>> getTransactions() async {
    final Database db = await getDatabase(getUserID());
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Transaction(
        transactionID: maps[i]['transactionID'],
        transactionType: maps[i]['transactionType'],
        recurring: maps[i]['recurring'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        category: maps[i]['category'],
        description: maps[i]['description'],
      );
    });
  }

  static Future<List<Transaction>> getSavingsTransactions() async {
    final Database db = await getDatabase(getUserID());
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: ['Savings'],
    );
    return List.generate(maps.length, (i) {
      return Transaction(
        transactionID: maps[i]['transactionID'],
        transactionType: maps[i]['transactionType'],
        recurring: maps[i]['recurring'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        category: maps[i]['category'],
        description: maps[i]['description'],
      );
    });
  }
}

class Transaction {
  final int? transactionID;
  final String transactionType;
  final bool recurring;
  final DateTime dateTime;
  final String category;
  final String description;

  Transaction({
    this.transactionID,
    required this.transactionType,
    required this.recurring,
    required this.dateTime,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionType': transactionType,
      'recurring': recurring ? 1 : 0,
      'dateTime': dateTime.toIso8601String(),
      'category': category,
      'description': description,
    };
  }
}
