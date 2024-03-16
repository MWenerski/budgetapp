
import 'package:budgetapp/profile.dart';

import 'package:flutter/material.dart';
import 'main.dart';
import 'savings.dart';
class Buttons {
  static Widget homeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()), 
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF283B41), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0), 
        ),
      ),
      child: SizedBox(
        height: 72.0,
        width: 80.0,
        child: Center(
          child: Image.asset(
            'assets/house-black-silhouette-without-door.png',
            height: 40.0,
            width: 40.0,
          ),
        ),
      ),
    );
  }

 static Widget incomeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Income()), 
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF283B41), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0), 
        ),
      ),
      child: SizedBox(
        height: 72.0,
        width: 80.0,
        child: Center(
          child: Image.asset(
            'assets/income.png', 
            height: 40.0,
            width: 40.0,
          ),
        ),
      ),
    );
  }
static Widget expenseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Expense()), 
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF283B41), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0), 
        ),
      ),
      child: SizedBox(
        height: 72.0,
        width: 80.0,
        child: Center(
          child: Image.asset(
            'assets/expenses.png', 
            height: 40.0,
            width: 40.0,
          ),
        ),
      ),
    );
  }

 
static Widget profileButton(BuildContext context, String globalUserName) {
    String initial = globalUserName.isNotEmpty ? globalUserName[0] : '?';

    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF283B41),
        shape: CircleBorder(),
      ),
      child: Container(
        height: 72.0,
        width: 72.0,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
 static Widget budgetButton(BuildContext context, double budget) {
  String buttonText = 'Budget: $budget';

  return ElevatedButton(
    onPressed: () {
      
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF283B41),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9.0),
      ),
    ),
    child: Container(
      height: 72.0,
      width: 148.0,
      alignment: Alignment.center,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}
static Widget savingsButton(BuildContext context, double savings) {
  String buttonText = 'Savings: $savings';

  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Savings()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF283B41),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9.0),
      ),
    ),
    child: Container(
      height: 72.0,
      width: 148.0,
      alignment: Alignment.center,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}
}