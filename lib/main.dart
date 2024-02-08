// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:budgetapp/Transactions.dart' as BudgetTransactions;
import 'package:budgetapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'buttons.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AuthHandler().initDatabase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool('stayLoggedIn') ?? false;
  runApp(MyApp(loggedIn));
}

class MyApp extends StatelessWidget {
  final bool RememberLogin;
  MyApp(this.RememberLogin);

  Widget build(BuildContext context) {
    return MaterialApp(
     home: RememberLogin ? Home() : LoginWidget(),
    );
  }
}


///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////


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
  BudgetTransactions.TransactionsDB.initDatabase(userID);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Home()),
  );
}
  }

  void register(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    await AuthHandler().registerUser(username, password);
    bool usernameAvailable = await AuthHandler().usernameNotTaken(username);
    if (username.isNotEmpty && password.isNotEmpty && usernameAvailable) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have successfully registered!'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (rememberLogin) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('stayLoggedIn', true);
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
                child: Text('Log In'),
              ),
            ],
          );
        },
      );
     } else if(!usernameAvailable){
       Fluttertoast.showToast(
      msg: 'This Username is already taken',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      backgroundColor: Color(0xFF283B41),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }else {
      Fluttertoast.showToast(
      msg: 'Username/Password cannot be empty',
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

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////




class Income extends StatelessWidget {
  final TextEditingController transactionAmountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool recurringValue = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Set app bar background color to black
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => Home()), 
        );
          },
        ),
        title: Text('Income Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: transactionAmountController,
              decoration: InputDecoration(
                labelText: 'Transaction Amount',
                labelStyle: TextStyle(color: Colors.white), // Set label text color
                border: OutlineInputBorder(), // Add border for text field
                enabledBorder: OutlineInputBorder( // Style border when enabled
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white), // Set text color
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Recurring',
                  style: TextStyle(color: Colors.white), // Set text color
                ),
                Checkbox(
                  value: recurringValue,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      recurringValue = newValue;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            DateTimePicker(
              controller: descriptionController,
              labelText: 'Date',
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitData(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitData(BuildContext context) async {
    final double transactionAmount = double.tryParse(transactionAmountController.text) ?? 0.0;
    final String dateTime = descriptionController.text;
    final String category = categoryController.text;
    final String description = descriptionController.text;

   final Database database = await BudgetTransactions.TransactionsDB.initDatabase(getUserID());

    await database.insert(
      tableName,
      {
        'transactionType': 'Expense',
        'transactionAmount': transactionAmount,
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
      content: Text('Data submitted successfully'),
    ));
  }
  static const String tableName = 'transactions';
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
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () => _selectDate(context),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}


class Expense extends StatelessWidget {
  final TextEditingController transactionAmountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool recurringValue = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Expense Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: transactionAmountController,
              decoration: InputDecoration(
                labelText: 'Transaction Amount',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Recurring'),
                Checkbox(
                  value: recurringValue,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      recurringValue = newValue;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            DateTimePicker(
              controller: descriptionController,
              labelText: 'Date',
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitData(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitData(BuildContext context) async {
    final double transactionAmount = double.tryParse(transactionAmountController.text) ?? 0.0;
    final String dateTime = descriptionController.text;
    final String category = categoryController.text;
    final String description = descriptionController.text;

    final Database database = await BudgetTransactions.TransactionsDB.initDatabase(getUserID());

    await database.insert(
      tableName,
      {
        'transactionType': 'Expense',
        'transactionAmount': transactionAmount,
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
      content: Text('Data submitted successfully'),
    ));
  }

  static const String tableName = 'transactions';
}

// Custom DateTimePicker widget
class _DateTimePicker extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const _DateTimePicker({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  @override
  DateTimePickerState createState() => DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
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



///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

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
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            );
          }
        },
      ),
    ),
    Positioned(
      top: 90, // Adjusted position of the white box
      bottom: 168, // Adjusted position of the white box
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
            Buttons.expenseButton(context),
            Buttons.homeButton(context),
            Buttons.incomeButton(context),
          ],
        ),
      ],
    ),
    Positioned(
      top: 0,
      right: 0,
      child: Buttons.profileButton(context, globalUserName),
    ),
  ],
),

      ),
    );
  }

  Future<String> generateMessage() async {
    DateTime now = DateTime.now();
    int hour = now.hour;
    String name = await fetchDisplayNameFromPrefs();
    if (hour < 12) {
      return 'Good Morning, $name!';
    } else if (hour < 17) {
      return 'Good Afternoon, $name!';
    } else {
      return 'Good Evening, $name!';
    }
  }
}

void stayLoggedIn() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if((prefs.getBool('stayLoggedIn') != null)){
      bool i = prefs.getBool('stayLoggedIn') as bool;
      
    if((i == true)){
     int? num = prefs.getInt('ID');
     if(num != null ){updateInfo(num);}
   }
  }
  
  
}

void updateInfo(int ID) async{
      String? temp1 = "";
      temp1 = await AuthHandler().getUsernameById(ID);
      if (temp1 != null){
         globalUserName = temp1;
      }

      String? temp2 = "";
      temp2 = await AuthHandler().getDisplayNameById(ID);
      if (temp2 != null){
        DisplayName  = temp2;
      }
       
}
Future<void> setDisplayNameInPrefs(String displayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', displayName);
    print('Display Name set in SharedPreferences: $displayName');
  }
  Future<String> fetchDisplayNameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('name');
    if (displayName != null) {
      return displayName;
    } else {
      print('No Display Name found in SharedPreferences');
      return "user";
    }
  }
  Future<bool> checkStayLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool stayLoggedIn = prefs.getBool('stayLoggedIn') ?? false; 
  return stayLoggedIn;
}

class Savings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Enter New Savings Goal'),
                            // Add your form here to change the savings goal
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Change button color to blue
                      foregroundColor: Colors.white, // Change text color to white
                      elevation: 0, // Remove button elevation
                      shadowColor: Colors.transparent, // Remove button shadow
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Add padding to the button
                    ),
                    child: Text(
                      'Change Savings Goal',
                      style: TextStyle(
                        fontSize: 20.0, // Increase text size
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<BudgetTransactions.Transaction>>(
                  future: BudgetTransactions.TransactionsDB.getSavingsTransactions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.0),
                            Text(
                              'No savings transactions found.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              'Savings Transactions',
                              style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10.0),
                            DataTable(
                              columns: [
                                DataColumn(label: Text('Transaction ID')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Date/Time')),
                                DataColumn(label: Text('Description')),
                              ],
                              rows: snapshot.data!.map<DataRow>((transaction) {
                                return DataRow(cells: [
                                  DataCell(Text(transaction.transactionID.toString())),
                                  DataCell(Text(transaction.transactionType)),
                                  DataCell(Text(transaction.transactionAmount.toString())),
                                  DataCell(Text(transaction.dateTime.toString())),
                                  DataCell(Text(transaction.description)),
                                ]);
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
     floatingActionButton: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Center(
            child: Buttons.homeButton(context),
          ),
        ),
    )
    );
    
    
  }
}
