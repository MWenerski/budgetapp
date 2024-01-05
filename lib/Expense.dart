import 'package:flutter/material.dart';
import 'buttons.dart';

class Expense extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Page'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black, 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Buttons.homeButton(context),
            ],
          ),
        ],
      ),
    );
  }
}
