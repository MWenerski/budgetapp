// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:budgetapp/Transactions.dart' as budget_transactions;
import 'package:budgetapp/Profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'buttons.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

budget_transactions.TransactionsDB transactionsDB =
    budget_transactions.TransactionsDB();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthHandler().initDatabase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool('stayLoggedIn') ?? false;
  runApp(MyApp(loggedIn));
}

class MyApp extends StatelessWidget {
  late Future<List<budget_transactions.TransactionsDB>> futureTransactions;
  final bool rememberLoginBool;
  MyApp(this.rememberLoginBool);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: rememberLoginBool ? Home() : LoginWidget(),
    );
  }
}

class LoginWidget extends StatefulWidget {
  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberLogin = false;
  void login(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    bool isAuthed = await AuthHandler().authenticateUser(username, password);
    if ((username.isNotEmpty || password.isNotEmpty) && isAuthed) {
      print('works');
      int userID = await AuthHandler().fetchID(username);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (rememberLogin) {
        prefs.setBool('stayLoggedIn', true);
        prefs.setInt('ID', userID);
      } else {
        prefs.remove('stayLoggedIn');
        prefs.remove('ID');
      }
      globalUser = userID;
      await transactionsDB.initDatabase(userID);
      if (prefs.getBool('$userID+log') != null) {
        print(globalUserName);
        print(displayName);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        prefs.setBool('$userID+log', true);
        print(globalUserName);
        print(displayName);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
      }
    }
  }

  void register(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    bool usernameisTaken = await AuthHandler().usernameTaken(username);
    bool userOK = Validator().validateUserInput(username, 'username');
    bool passOK = Validator().validateUserPassword(password);
    if (userOK && passOK && !usernameisTaken) {
      await AuthHandler().registerUser(username, password);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have successfully registered!'),
          );
        },
      );
    } else if (usernameisTaken) {
      Fluttertoast.showToast(
        msg: 'This Username is already taken',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 4,
        backgroundColor: Color(0xFF283B41),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox(
                    value: rememberLogin,
                    onChanged: (value) {
                      setState(() {
                        rememberLogin = value!;
                      });
                    },
                  ),
                  Text(
                    'Keep me logged in',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => login(context),
                child: Text('Login'),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () => register(context),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionPage extends StatefulWidget {
  @override
  TransactionPageState createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  final TextEditingController transactionAmountController =TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool recurringValue = false;
  String transactionType = 'Income';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        title: Text(
            transactionType == 'Income' ? 'Income Page' : 'Expense Page',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: transactionType,
              onChanged: (newValue) {
                setState(() {
                  transactionType = newValue!;
                });
              },
              items: <String>['Income', 'Expense']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            _buildTextField(
              labelText: 'Transaction Amount',
              controller: transactionAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              suffixText: '.00',
            ),
            SizedBox(height: 16),
            _buildRecurringCheckbox(),
            SizedBox(height: 16),
            DateTimePicker(
              controller: descriptionController,
              labelText: 'Date',
            ),
            _buildTextField(
              labelText: 'Category',
              controller: categoryController,
              suffixText: transactionType == 'Income' ? 'Savings' : null,
            ),
            _buildTextField(
              labelText: 'Description',
              controller: descriptionController,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixText: suffixText,
      ),
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildRecurringCheckbox() {
    return Row(
      children: [
        Text(
          'Recurring',
          style: TextStyle(color: Colors.white),
        ),
        Checkbox(
          value: recurringValue,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                recurringValue = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  void _submitData() async {
    final double transactionAmount =
        double.tryParse(transactionAmountController.text) ?? 0.0;
    final String formattedAmount = transactionAmount.toStringAsFixed(2);
    final String dateTime = descriptionController.text;
    final String category = categoryController.text.toLowerCase() == 'savings'
        ? 'Savings'
        : categoryController.text;
    final String description = descriptionController.text;

    budget_transactions.TransactionsDB transactionsDB =
        budget_transactions.TransactionsDB();
    Database database = await transactionsDB.getDatabase(globalUser);

    await database.insert(
      'Transactions',
      {
        'transactionType': transactionType,
        'transactionAmount': formattedAmount,
        'recurring': recurringValue ? 1 : 0,
        'dateTime': dateTime,
        'category': category,
        'description': description,
      },
    );

    transactionAmountController.clear();
    categoryController.clear();
    descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data submitted successfully',
          style: TextStyle(color: Colors.white)),
    ));
  }
}

class DateTimePicker extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const DateTimePicker({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  @override
  DateTimePickerState createState() => DateTimePickerState();
}

class DateTimePickerState extends State<DateTimePicker> {
  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: FutureBuilder<String>(
                future: generateMessage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF283B41),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Text(
                        snapshot.data ?? '',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: 90,
              bottom: 168,
              left: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(9.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9.0),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Buttons.budgetButton(context, globalBudget),
                    Buttons.savingsButton(context, globalSavings),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                   
                    Buttons.newTransactionButton(context),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Buttons.profileButton(context, displayName),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> generateMessage() async {
    String _displayname = await AuthHandler().fetchDisplayName(globalUserName);
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour < 12) {
      return 'Good Morning, $_displayname!';
    } else if (hour < 17) {
      return 'Good Afternoon, $_displayname!';
    } else {
      return 'Good Evening, $_displayname!';
    }
  }
}

void stayLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if ((prefs.getBool('stayLoggedIn') != null)) {
    bool i = prefs.getBool('stayLoggedIn') as bool;
    if ((i == true)) {
      int? num = prefs.getInt('ID');
      if (num != null) {
        updateInfo(num);
      }
    }
  }
}

void updateInfo(int ID) async {
  String? temp1 = "";
  temp1 = await AuthHandler().getUsernameById(ID);
  if (temp1 != null) {
    globalUserName = temp1;
  }

  String? temp2 = "";
  temp2 = await AuthHandler().getDisplayNameById(ID);
  if (temp2 != null) {
    displayName = temp2;
  }
}

Future<void> setDisplayNameInPrefs(String displayName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('displayName', displayName);
  print('Display Name set in SharedPreferences: $displayName');
}
