
import 'package:flutter/material.dart';
import 'Expense.dart';
import 'Income.dart';
import 'buttons.dart';
void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 36), // Spacer to create vertical space
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExpenseButton(),
            Buttons.homeButton(context),
            IncomeButton(),
          ],
        ),
      ],
    );
  }
}
class IncomeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 72,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Income()), 
            );
        },
        child: Text('Income'),
      ),
    );
  }
}
class ExpenseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 72,
      child: ElevatedButton(
        onPressed: () {
         Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Expense()), 
            );
        },
        child: Text('Expense'),
      ),
    );
  }
}