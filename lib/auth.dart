
import 'package:bcrypt/bcrypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'globals.dart';

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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        displayname TEXT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    });
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    try {
      List<Map<String, dynamic>> entries = await _database.query('users');
      return entries;
    } catch (e) {
      print('Error fetching entries: $e');
      return [];
    }
  }

  Future<void> registerUser(String username, String password) async {
    try {
      String salt = BCrypt.gensalt();
      String hashedPassword = BCrypt.hashpw(password, salt);

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
            BCrypt.checkpw(password, storedHashedPassword);
        return isPasswordCorrect;
      } else {
        return false;
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

  Future<int> fetchID(String name) async {
    try {
      List<Map<String, dynamic>> results = await _database.query(
        'users',
        columns: ['id'],
        where: 'username = ?',
        whereArgs: [name],
      );

      if (results.isNotEmpty) {
        dynamic idValue = results.first['id'];

        if (idValue != null) {
          int? num = int.tryParse(idValue.toString());

          if (num != null) {
            
            return num;
          } else {
            throw Exception('Invalid Name or no ID assigned');
          }
        } else {
          throw Exception('Null Name found for ID');
        }
      } else {
        throw Exception('No Name Found for ID');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> usernameTaken(String username) async {
    try {
      List<Map<String, dynamic>> results = await _database.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> fetchDisplayName(String name) async {
    try {
      List<Map<String, dynamic>> results = await _database.query(
        'users',
        columns: ['displayname'],
        where: 'username = ?',
        whereArgs: [name],
      );

      if (results.isNotEmpty) {
        String? temp3 = results.first['displayname'];
        if (temp3 != null) {
          return temp3;
        } else {
          throw Exception('No display name assigned');
        }
      } else {
        throw Exception('Invalid Name or no display name assigned');
      }
    } catch (e) {
      throw Exception('Error fetching display name: $e');
    }
  }

  Future<void> setDisplayName(String username, String newValue) async {
    await _database.update(
      'users',
      {'displayname': newValue},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<String?> getUsernameById(int userId) async {
    List<Map<String, dynamic>> results = await _database.query(
      'users',
      columns: ['username'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return results.first['username'] as String?;
    } else {
      return null;
    }
  }

  Future<String?> getDisplayNameById(int userId) async {
    List<Map<String, dynamic>> results = await _database.query(
      'users',
      columns: ['displayname'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return results.first['displayname'] as String?;
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('stayLoggedIn', false);
    prefs.setInt('ID', 0);
    resetUserGlobals();
  }
    Future<void> deleteAccount(int id) async {
  String? username = await getUsernameById(id);
  if (username != null) {
    await _database.delete(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
  } else {
    throw Exception('Username not found for ID: $id');
  }
}
  }

class Validator {
  bool validateUserInput(String input, String use) {
    switch (input.length) {
      case 0:
        Fluttertoast.showToast(msg: 'the $use cannot be empty');
        return (false);
      case 1:
        Fluttertoast.showToast(
            msg: 'The $use must be at least 2 characters long');
        return (false);
      default:
        if (input.length > 10) {
          Fluttertoast.showToast(
              msg: 'The $use must be at most 10 characters long');
          return (false);
        } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(input)) {
          Fluttertoast.showToast(msg: 'The $use must only contain letters');
          return (false);
        } else {
          return (true);
        }
    }
  }
  bool validateUserPassword(String input) {
    switch (input.length) {
      case 0:
        Fluttertoast.showToast(msg: 'the password cannot be empty');
        return (false);
      case 1:
        Fluttertoast.showToast(
            msg: 'The password must be at least 2 characters long');
        return (false);
      default:
        if (input.length > 15) {
          Fluttertoast.showToast(
              msg: 'The password must be at most 15 characters long');
          return (false);
        }  else {
          return (true);
        }
    }
  }
}
