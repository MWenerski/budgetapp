import 'package:budgetapp/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        // Check if it's the first launch by checking if 'firstLaunch' is null in SharedPreferences
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            SharedPreferences prefs = snapshot.data!;
            bool firstLaunch = prefs.getBool('firstLaunch') ?? true;

            if (firstLaunch) {
              // If it's the first launch, show the setup page
              return ProfileSetup();
            } else {
              // If it's not the first launch, fetch the user's name and go to the home page
              String userName = prefs.getString('name') ?? 'Default Name';
             
              return Home(userName: userName);
            }
          }
          return CircularProgressIndicator(); // Loading indicator while checking
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class ProfileSetup extends StatelessWidget {
  TextEditingController nameController = TextEditingController();
  String selectedCurrency = 'GBP'; // Default currency

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile Setup'),
      ),
      backgroundColor: Colors.black, // Set the background color of the entire page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (String? value) {
                // Update the selected currency
                if (value != null) {
                  selectedCurrency = value;
                }
              },
              items: ['GBP', 'USD', 'EUR', 'JPY', 'CAD', 'AUD'] // Add more currencies as needed
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16),
           ElevatedButton(
  onPressed: () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstLaunch', false);
    prefs.setString('name', nameController.text);
    prefs.setString('currency', selectedCurrency);
    initializeUserGlobals(nameController.text, selectedCurrency);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(userName: nameController.text),
      ),
    );
  },
  child: Text('Save and Continue'),
),
          ],
        ),
      ),
    );
  }
}
