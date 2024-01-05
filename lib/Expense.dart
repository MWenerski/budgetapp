import 'package:flutter/material.dart';

class Expense extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense.dart'),
      ),
      body: Center(
        child: Text('This is Expense.dart - Page 2.'),
      ),
    );
  }
}