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
  int userID = await AuthHandler().fetchID(username); // Await the result of the future
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  if (rememberLogin) {
    prefs.setBool('stayLoggedIn', true);
    prefs.setInt('ID', userID); // Store the user ID in SharedPreferences
  } else {
    prefs.remove('stayLoggedIn'); // Remove stayLoggedIn if not remembered
    prefs.remove('ID'); // Remove ID from SharedPreferences
  }

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        automaticallyImplyLeading: false,
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