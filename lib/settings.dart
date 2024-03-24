import 'package:budgetapp/profile.dart';
import 'package:budgetapp/transactions.dart';
import 'package:budgetapp/auth.dart';
import 'package:budgetapp/globals.dart';
import 'package:budgetapp/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        title: Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF283B41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              minimumSize: Size(148, 72),
            ),
            child: Text(
              'Change Preferences',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              AuthHandler().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginWidget()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF283B41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              minimumSize: Size(176, 72),
            ),
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 250),
          ElevatedButton(
            onPressed: () {
            
              _showDeleteAccountConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 109, 22, 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountConfirmationDialog extends StatefulWidget {
  @override
  _DeleteAccountConfirmationDialogState createState() =>
      _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState
    extends State<_DeleteAccountConfirmationDialog> {
  TextEditingController usernameController = TextEditingController();
  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Input your username to confirm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      isConfirmed = value!;
                    });
                  },
                ),
                Text('I want my account deleted'),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String? a = await AuthHandler().getUsernameById(globalUser);
                if (usernameController.text == a && isConfirmed) {
                  TransactionsDB().deleteTransactions();
                  AuthHandler().deleteAccount(globalUser);
                  AuthHandler().logout();
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginWidget()),
                  );
                  Fluttertoast.showToast(
                    msg: "Your account was successfully deleted",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Unable to delete your account, please try again",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteAccountConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _DeleteAccountConfirmationDialog();
    },
  );
}
