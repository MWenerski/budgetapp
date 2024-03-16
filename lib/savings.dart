import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:budgetapp/Transactions.dart' as BudgetTransactions;
import 'buttons.dart';

class Savings extends StatefulWidget {
  @override
  _SavingsState createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  late Future<List<BudgetTransactions.Transaction>> futureTransactions;
  final BudgetTransactions.TransactionsDB transactionsDB = BudgetTransactions.TransactionsDB();

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
            'Current Savings Goal:',
            style: TextStyle(color: Colors.white, fontSize: 24.0),
          ),
          Text(
            '$globalCurrency $globalSavings',
            style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Enter New Savings Goal'),
                    // Add your form here to change the savings goal
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 100.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9.0),
                  topRight: Radius.circular(9.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[800],
                  child: FutureBuilder<List<BudgetTransactions.Transaction>>(
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
                        snapshot.data!.sort((a, b) => b.dateTime.compareTo(a.dateTime));
                        return SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 10.0,
                            columns: [
                              DataColumn(label: Text('Transaction ID', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text('Date', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                            ],
                            rows: snapshot.data!.map<DataRow>((transaction) {
                              return DataRow(cells: [
                                DataCell(Text(transaction.transactionID.toString(), style: TextStyle(color: Colors.white))),
                                DataCell(Text(transaction.transactionAmount.toStringAsFixed(2), style: TextStyle(color: Colors.white))),
                                DataCell(Text(_formatDate(transaction.dateTime), style: TextStyle(color: Colors.white))),
                                DataCell(Text(transaction.description, style: TextStyle(color: Colors.white))),
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}