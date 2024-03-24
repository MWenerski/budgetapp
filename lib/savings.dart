import 'package:budgetapp/carousel.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:budgetapp/transactions.dart' as budget_transactions;
import 'buttons.dart';

class Savings extends StatefulWidget {
  @override
  SavingsState createState() => SavingsState();
}

class SavingsState extends State<Savings> {
  late Future<List<budget_transactions.Transaction>> futureTransactions;
  final budget_transactions.TransactionsDB transactionsDB =
      budget_transactions.TransactionsDB();

  @override
  void initState() {
    super.initState();
    futureTransactions = transactionsDB.getSavingsTransactions();
  }

  String tableName = 'transactions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50.0),
          Text(
            'Current Savings:',
            style: TextStyle(color: Colors.white, fontSize: 24.0),
          ),
          FutureBuilder<double>(
            future: TransactionAnalyzer().getTotalSavings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                double totalSavings = snapshot.data ?? 0.0;
                return Text(
                  '$globalCurrency $totalSavings',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Enter New Savings Goal'),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF283B41),
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            ),
            child: Text(
              'Change Savings Goal',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 100.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9.0),
                  topRight: Radius.circular(9.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[800],
                  child: FutureBuilder<List<budget_transactions.Transaction>>(
                    future: futureTransactions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.0),
                              Text(
                                'No savings transactions found.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      } else {
                        snapshot.data!
                            .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                        return SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 10.0,
                            columns: [
                              DataColumn(
                                  label: Text('Transaction ID',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Amount',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Date',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Description',
                                      style: TextStyle(color: Colors.white))),
                            ],
                            rows: snapshot.data!.map<DataRow>((transaction) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    transaction.transactionID.toString(),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(
                                    transaction.transactionAmount
                                        .toStringAsFixed(2),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(transaction.dateTime,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(transaction.description,
                                    style: TextStyle(color: Colors.white))),
                              ]);
                            }).toList(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Buttons.homeButton(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
