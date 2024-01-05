
import 'package:budgetapp/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
 
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<Profile> {
  TextEditingController nameController = TextEditingController();
  String selectedCurrency = 'GBP'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
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
                saveUserData();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home(userName: '',)),
                );
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
}
