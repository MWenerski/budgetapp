import 'package:budgetapp/transactions.dart' as budget_transactions;
import 'package:budgetapp/carousel.dart';
import 'package:budgetapp/globals.dart';
import 'package:budgetapp/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  TransactionPageState createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  final TextEditingController transactionAmountController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool recurringValue = false;
  String transactionType = 'Income';
  String selectedCategory = '';

  List<String> incomeCategories = ['Salary', 'Bonus', 'Gift', 'Other'];
  List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Other'
  ];

  List<String> get categories {
    return transactionType == 'Income'
        ? incomeCategories
        : [...expenseCategories, 'Savings'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            TransactionAnalyzer().calculateBudget();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: transactionType,
                  onChanged: (newValue) {
                    setState(() {
                      transactionType = newValue!;
                    });
                  },
                  items: <String>['Income', 'Expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: const Color.fromARGB(255, 63, 63, 63),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildCategoryDropdown(),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildTextField(
              labelText: 'Transaction Amount',
              controller: transactionAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 24),
            DateTimePicker(
              dateController: dateController,
              labelText: 'Date',
            ),
            SizedBox(height: 24),
            _buildTextField(
              labelText: 'Description',
              controller: descriptionController,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                _submitData();
                await TransactionAnalyzer().calculateBudget();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text('Submit', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildCategoryDropdown() {
    List<String> incomeCategories = [
      'Salary',
      'Freelance',
      'Investment',
      'Gift',
      'Other'
    ];
    List<String> expenseCategories = [
      'Groceries',
      'Utilities',
      'Travel',
      'Entertainment',
      'Healthcare',
      'Savings',
      'Other'
    ];

    List<String> allCategories = [];

    if (transactionType == 'Income') {
      allCategories.addAll(incomeCategories);
    } else {
      allCategories.addAll(expenseCategories);
    }

    if (!allCategories.contains(selectedCategory)) {
      selectedCategory = allCategories.first;
    }

    return DropdownButton<String>(
      value: selectedCategory,
      onChanged: (newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
      },
      items: allCategories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      dropdownColor: const Color.fromARGB(255, 63, 63, 63),
    );
  }

  void _submitData() async {
    final double transactionAmount =
        double.tryParse(transactionAmountController.text) ?? 0.0;
    final String formattedAmount = transactionAmount.toStringAsFixed(2);
    final String dateTime = dateController.text;
    final String category = selectedCategory.toLowerCase() == 'savings'
        ? 'Savings'
        : selectedCategory;
    final String description = descriptionController.text;

    budget_transactions.TransactionsDB transactionsDB =
        budget_transactions.TransactionsDB();
    Database database = await transactionsDB.getDatabase(globalUser);

    await database.insert(
      'Transactions',
      {
        'transactionType': transactionType,
        'transactionAmount': formattedAmount,
        'recurring': recurringValue ? 1 : 0,
        'dateTime': dateTime,
        'category': category,
        'description': description,
      },
    );

    transactionAmountController.clear();
    descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Data submitted successfully',
        style: TextStyle(color: Colors.white),
      ),
    ));
  }
}

class DateTimePicker extends StatefulWidget {
  final TextEditingController dateController;
  final String labelText;

  const DateTimePicker({
    Key? key,
    required this.dateController,
    required this.labelText,
  }) : super(key: key);

  @override
  DateTimePickerState createState() => DateTimePickerState();
}

class DateTimePickerState extends State<DateTimePicker> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
