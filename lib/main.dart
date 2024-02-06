// ignore_for_file: use_build_context_synchronously

import 'package:budgetapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buttons.dart';
import 'globals.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AuthHandler().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     home: Home(),
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
    bool keepLoggedIn = false;

  saveKeepLoggedInState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('keepLoggedIn', value);
  }

  void login(BuildContext context) async{
    String username = usernameController.text;
    String password = passwordController.text;
    bool isAuthed = await AuthHandler().authenticateUser(username, password);
    if((username  != ""|| password != "") & isAuthed){
      globalUser = await AuthHandler().fetchID(username);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  void register(BuildContext context) async{
    String username = usernameController.text;
    String password = passwordController.text;
    BuildContext localContext = context;
    await AuthHandler().registerUser(username, password);
    bool usernameAvailable = await AuthHandler().usernameNotTaken(username);
    if((username  != ""|| password != "")&& (usernameAvailable )){
    showDialog(
      context: localContext,
      builder: (BuildContext localContext) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered!'),
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
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
                    value: keepLoggedIn,
                    onChanged: (value) {
                      setState(() {
                        keepLoggedIn = value!;
                        saveKeepLoggedInState(keepLoggedIn);
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
                onPressed:() => register(context),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text('This is the Income Page'),
            ),
          ),
          Buttons.homeButton(context)
        ],
      ),
    );
  }
}

class Expense extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text('This is the Expense Page'),
            ),
          ),
          Buttons.homeButton(context)
        ],
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
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF283B41),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  generateMessage(),
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 36),
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

  String generateMessage() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return 'Good Morning, $globalUserName!';
    } else if (hour < 17) {
      return 'Good Afternoon, $globalUserName!';
    } else {
      return 'Good Evening, $globalUserName!';
    }
  }
}


///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///
///
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///
///
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
