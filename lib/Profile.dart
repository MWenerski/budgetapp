import 'package:budgetapp/auth.dart';
import 'package:budgetapp/globals.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:budgetapp/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;


class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  TextEditingController nameController = TextEditingController();
  String selectedCurrency = 'GBP';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text('Profile Setup'),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (String? value) {
                setState(() {
                  selectedCurrency = value ?? 'GBP';
                });
              },
              items: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CNY', 'INR', 'BRL']
                  .map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(nameController.text == ""){
                  Fluttertoast.showToast(
                  msg: 'Display Name cannot be empty',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 4,
                  backgroundColor: Color(0xFF283B41),
                  textColor: Colors.white,
                  fontSize: 16.0,
                   );

                }else{
                  saveUserData();
                  globals.initializeUserGlobals(nameController.text, selectedCurrency);
                  AuthHandler().setDisplayName(nameController.text,globalUserName);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                ); 
              }
               
              },
              child: Text('Save and Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('name', nameController.text);
    prefs.setString('currency', selectedCurrency);
  }
  void logout(){
    AuthHandler().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginWidget()),
    );
  }
}
