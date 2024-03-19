import 'package:budgetapp/Transactions.dart';
import 'package:budgetapp/globals.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DatabaseHelper {
  Future<TransactionsDB> getTransactionsDatabase() async {
    try {
      TransactionsDB transactionsDB = TransactionsDB();
      await transactionsDB.initDatabase(globalUser);
      return transactionsDB;
    } catch (e) {
      print('Error getting transactions database: $e');
      rethrow;
    }
  }
}

class TransactionAnalyzer {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Map<String, double>> getTransactionTotalsLast30Days() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 29));

      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDateStr = formatter.format(startDate);
      String endDateStr = formatter.format(endDate);

      TransactionsDB transactionsDB = await _databaseHelper.getTransactionsDatabase();
      print('Start Date: $startDate, End Date: $endDate');
      List<Transaction> transactions = await transactionsDB.getTransactionsBetweenDates(startDateStr, endDateStr);
      print('Transactions: $transactions');
      Map<String, double> categoryTotals = {};

      for (Transaction transaction in transactions) {
        String category = transaction.category;
        double amount = transaction.transactionAmount;

        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }
      return categoryTotals;
    } catch (e) {
      print('Error getting transaction totals for last 30 days: $e');
      rethrow;
    }
  }
}

class CarouselWidget extends StatefulWidget {
  @override
  CarouselWidgetState createState() => CarouselWidgetState();
}

class CarouselWidgetState extends State<CarouselWidget> {
  final TransactionAnalyzer _transactionAnalyzer = TransactionAnalyzer();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _transactionAnalyzer.getTransactionTotalsLast30Days(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return _buildCarousel(snapshot.data!);
        } else {
          return Center(
            child: Text('No data available'),
          );
        }
      },
    );
  }

  Widget _buildCarousel(Map<String, double> categoryTotals) {
    return CarouselSlider.builder(
      itemCount: categoryTotals.length,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final category = categoryTotals.keys.elementAt(index);
        final total = categoryTotals[category]!;

        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$$total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 2,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
      ),
    );
  }
}
