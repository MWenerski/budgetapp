import 'package:budgetapp/globals.dart';
import 'package:budgetapp/main.dart';
import 'package:flutter/material.dart';
import 'transactions.dart';

class ViewTransactions extends StatefulWidget {
  @override
  ViewTransactionsState createState() => ViewTransactionsState();
}

class ViewTransactionsState extends State<ViewTransactions> {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    List<Transaction> transactions = await TransactionsDB().getTransactions();
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return transactions;
  }

  String _formatCurrency(double amount) {
    Map<String, String> currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'CA\$',
      'AUD': 'A\$',
      'CNY': '¥',
      'INR': '₹',
      'BRL': 'R\$',
    };
    String currencySymbol = currencySymbols[globalCurrency] ?? '\$';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'View Transactions',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      backgroundColor: Colors.grey[900], 
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView(
              children: [
                DataTable(
                  columnSpacing: 8.0,
                  columns: [
                    DataColumn(
                      label: Text('Date', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Amount', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Type', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Category', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  rows: transactions
                      .map(
                        (transaction) => DataRow(
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              _showTransactionDescription(transaction.description);
                            }
                          },
                          cells: [
                            DataCell(Text(transaction.dateTime, style: TextStyle(color: Colors.white))),
                            DataCell(Text(_formatCurrency(transaction.transactionAmount), style: TextStyle(color: Colors.white))),
                            DataCell(Text(transaction.transactionType, style: TextStyle(color: Colors.white))),
                            DataCell(Text(transaction.category, style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showTransactionDescription(String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction Description', style: TextStyle(color: Colors.white)),
          content: Text(description, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
