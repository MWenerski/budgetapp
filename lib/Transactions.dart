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
          CREATE TABLE $tableName(
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
        dateTime: DateTime.parse(maps[i]['dateTime']),
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
      String dateTimeString = maps[i]['dateTime'];
      DateTime dateTime;

    
      try {
        List<String> parts = dateTimeString.split('-');
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);

     
        dateTime = DateTime(year, month, day);
      } catch (e) {

        print('Error parsing date: $e');

        dateTime = DateTime.now();
      }

      return Transaction(
        transactionID: maps[i]['transactionID'],
        transactionType: maps[i]['transactionType'],
        transactionAmount: maps[i]['transactionAmount'],
        recurring: maps[i]['recurring'] == 1,
        dateTime: dateTime,
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
  
}

class Transaction {
  final int? transactionID;
  final String transactionType;
  final double transactionAmount;
  final bool recurring;
  final DateTime dateTime;
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
      'dateTime': dateTime.toIso8601String(),
      'category': category,
      'description': description,
    };
  }
}
