import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';


class AuthHandler {
  AuthHandler._();
  
  static final AuthHandler _instance = AuthHandler._();
  
  factory AuthHandler() {
    return _instance;
  }

  String databasePath = "lib/DB/login.db";
  late Database _database;

  Future<void> initDatabase() async {
    _database = await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT,
            password TEXT
          )
        ''');
    });
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    try {
      
      List<Map<String, dynamic>> entries = await _database.query('users');
      print(entries);
      return entries;
      
    } catch (e) {
      print('Error fetching entries: $e');
      return [];
    }
  }

  Future<void> registerUser(String username, String password) async {
    try {
      
      String salt = await BCrypt.gensalt();
      String hashedPassword = await BCrypt.hashpw(password, salt);

      await _database.insert(
        'users',
        {
          'username': username,
          'password': hashedPassword,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('error registering: $e');
    }
  }

  Future<bool> authenticateUser(String username, String password) async {
    try {
     
      List<Map<String, dynamic>> results = await _database.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (results.isNotEmpty) {
        Map<String, dynamic> user = results.first;
        String storedHashedPassword = user['password'];
        bool isPasswordCorrect =
            await BCrypt.checkpw(password, storedHashedPassword);
        return isPasswordCorrect;
      } else {
        return false; // User not found
      }
    } catch (e) {
      print('Error authenticating user: $e');
      return false;
    }
  }

  Future<void> addEntry(String username, String password) async {
    try {
      
      await _database.insert(
        'users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding entry: $e');
    }
  }

  Future<Map<String, dynamic>> fetchEntry(int id) async {
    try {
     
      List<Map<String, dynamic>> results = await _database.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      print(id); print(results);
      if (results.isNotEmpty) {
        return results.first;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching entry: $e');
      return {};
    }
  }

   Future<void> clearDatabase() async {
    try {

      await _database.delete('users');
      print('Database cleared successfully');
    } catch (e) {
      print('Error clearing database: $e');
    }
  }
}




