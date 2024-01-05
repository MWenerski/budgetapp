import 'package:budgetapp/globals.dart';
import 'package:flutter/material.dart';
import 'buttons.dart';

class Home extends StatelessWidget {
  final String userName;

  Home({required this.userName});

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