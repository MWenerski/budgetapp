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
        body: MyHomePage(userName: userName),
      ),
    );
  }
}
class MyHomePage extends StatelessWidget {
  final String userName;

  MyHomePage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
          child: Buttons.profileButton(context, userName),
        ),
      ],
    );
  }
}
