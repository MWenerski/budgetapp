import 'globals.dart';
import 'package:sqflite/sqflite.dart';

class TransactionsDB {
  Database? _database;

  String tableName = 'Transactions';

  Future<Database> getDatabase(int userId) async {
    if (_database != null) return _database!;
    _database = await initDatabase(userId);
    return _database!;
  }

  Future<Database> initDatabase(int userId) async {
    String databasePath = "lib/DB/transactions_$userId.db";
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Transactions (
            transactionID INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionType TEXT,
            transactionAmount DOUBLE,
            recurring INTEGER,
            dateTime TEXT,
            category TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final Database db = await getDatabase(getUserID());
    await db.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final Database db = await getDatabase(getUserID());
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Transaction(
        transactionID: maps[i]['transactionID'],
        transactionType: maps[i]['transactionType'],
        transactionAmount: maps[i]['transactionAmount'],
        recurring: maps[i]['recurring'] == 1,
        dateTime: maps[i]['dateTime'],
        category: maps[i]['category'],
        description: maps[i]['description'],
      );
    });
  }

  Future<List<Transaction>> getSavingsTransactions() async {
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
        transactionAmount: maps[i]['transactionAmount'],
        recurring: maps[i]['recurring'] == 1,
        dateTime: maps[i]['dateTime'],
        category: maps[i]['category'],
        description: maps[i]['description'],
      );
    });
  }

  Future<void> deleteTransactions() async {
    final Database db = await getDatabase(getUserID());
    await db.delete(
      tableName,
      where: '1',
    );
  }

  Future<List<Transaction>> getTransactionsBetweenDates(
      String startDate, String endDate) async {
    try {
      final db = await getDatabase(getUserID());
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: "dateTime BETWEEN ? AND ?",
        whereArgs: [startDate, endDate],
      );
      return List.generate(maps.length, (i) {
        return Transaction(
          transactionID: maps[i]['transactionID'],
          transactionType: maps[i]['transactionType'],
          transactionAmount: maps[i]['transactionAmount'],
          recurring: maps[i]['recurring'] == 1,
          category: maps[i]['category'],
          dateTime: maps[i]['dateTime'],
          description: maps[i]['description'],
        );
      });
    } catch (e) {
      print("Error retrieving transactions between dates: $e");
      return [];
    }
  }
}

class Transaction {
  final int? transactionID;
  final String transactionType;
  final double transactionAmount;
  final bool recurring;
  final String dateTime;
  final String category;
  final String description;

  Transaction({
    this.transactionID,
    required this.transactionType,
    required this.transactionAmount,
    required this.recurring,
    required this.dateTime,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionType': transactionType,
      'transactionAmount': transactionAmount,
      'recurring': recurring ? 1 : 0,
      'dateTime': dateTime,
      'category': category,
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionID: map['transactionID'],
      transactionType: map['transactionType'],
      transactionAmount: map['transactionAmount'],
      recurring: map['recurring'] == 1,
      dateTime: map['dateTime'],
      category: map['category'],
      description: map['description'],
    );
  }
}

