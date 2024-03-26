import 'package:budgetapp/globals.dart';
import 'package:budgetapp/settings.dart';
import 'package:budgetapp/view_transactions.dart';
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
        width: 148.0,
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

  static Widget newTransactionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransactionPage()),
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
        width: 350,
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

  static Widget profileButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
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
        child: Image.asset(
          'assets/settings.png',
          width: 32.0,
          height: 32.0,
        ),
      ),
    );
  }

  static Widget budgetButton(BuildContext context, double budget) {
    String buttonText = 'Budget: $budget';

    return ElevatedButton(
      onPressed: () {},
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
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  static Widget viewTransactionsButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewTransactions()),
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
      width: 350.0, 
      child: Center(
        child: Text(
          'View Transactions',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

}

class SavingsButton extends StatelessWidget {
  final double savings;
  final double savingsGoal;
  const SavingsButton({
    required this.savings,
    required this.savingsGoal,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = 'Savings: $savings';
    double progress = (savings / savingsGoal).clamp(0.0, 1.0);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[400],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan.shade900),
            ),
          ],
        ),
      ),
    );
  }
}
