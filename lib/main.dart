// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:budgetapp/transactions.dart' as budget_transactions;
import 'package:budgetapp/profile.dart';
import 'package:budgetapp/carousel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buttons.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        prefs.setBool('$userID+log', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
      }
      void fetchGlobalGoal() async {
        double goal = await globalGoalPrefs();
        setState(() {
          globalGoal = goal;
        });
      }
      fetchGlobalGoal();
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
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: 90,
              bottom: 252,
              left: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(181, 37, 37, 37),
                  borderRadius: BorderRadius.circular(9.0),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CarouselWidget(),
                SizedBox(height: 60),
                Buttons.viewTransactionsButton(context), 
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<double>(
                      future: globalBudget,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Buttons.budgetButton(
                              context, snapshot.data ?? 0.00);
                        }
                      },
                    ),
                    FutureBuilder<double>(
                      future: globalSavings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return SavingsButton(
                            savings: snapshot.data ?? 0.00,
                            savingsGoal:
                                globalGoal,
                          );
                        }
                      },
                    ),
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
              child: Buttons.profileButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> generateMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? displayName = prefs.getString('name');
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour < 12) {
      return 'Good Morning, $displayName!';
    } else if (hour < 17) {
      return 'Good Afternoon, $displayName!';
    } else {
      return 'Good Evening, $displayName!';
    }
  }
}
