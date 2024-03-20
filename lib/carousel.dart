import 'package:budgetapp/Transactions.dart';
import 'package:budgetapp/globals.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';

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

      TransactionsDB transactionsDB =
          await _databaseHelper.getTransactionsDatabase();
      print('Start Date: $startDate, End Date: $endDate');
      List<Transaction> transactions = await transactionsDB
          .getTransactionsBetweenDates(startDateStr, endDateStr);

      transactions = transactions
          .where((transaction) => transaction.transactionType == "Expense")
          .toList();

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
  final PieChartWidget pieChartWidget = PieChartWidget();
  final BarChartWidget barChartWidget = BarChartWidget();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: PieChartWidget.categoryTotalsFuture,
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
          return buildCarousel();
        } else {
          return Center(
            child: Text('No data available'),
          );
        }
      },
    );
  }

   Widget buildCarousel() {
  return CarouselSlider.builder(
    itemCount: 2,
    itemBuilder: (BuildContext context, int index, int realIndex) {
      return AnimatedOpacity(
        opacity: index == currentIndex ? 1.0 : 0.0,
        duration: Duration(seconds: 20),
        child: _buildCarouselItem(index),
      );
    },
    options: CarouselOptions(
      aspectRatio: 2,
      enlargeCenterPage: true,
      enableInfiniteScroll: false,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 8),
      onPageChanged: (index, reason) {
        setState(() {
          currentIndex = index;
        });
      },
    ),
  );
}

Widget _buildCarouselItem(int index) {
  switch (index) {
    case 0:
      return pieChartWidget;
    case 1:
      return barChartWidget;
    default:
      return Container(); 
  }
}
}

class PieChartWidget extends StatefulWidget {
  @override
  PieChartWidgetState createState() => PieChartWidgetState();

  static final TransactionAnalyzer analyzer = TransactionAnalyzer();
  static Future<Map<String, double>> get categoryTotalsFuture =>
      analyzer.getTransactionTotalsLast30Days();
}

class PieChartWidgetState extends State<PieChartWidget> {
  late Future<Map<String, double>> _categoryTotalsFuture;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future<void> _updateData() async {
    setState(() {
      _categoryTotalsFuture = PieChartWidget.categoryTotalsFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _categoryTotalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildPieChart(snapshot.data!);
        } else {
          return _buildEmptyPieChart();
        }
      },
    );
  }

 Widget _buildPieChart(Map<String, double> categoryTotals) {
  return AspectRatio(
    aspectRatio: 1,
    child: SizedBox(
      width: double.infinity,
      child: PieChart(
        PieChartData(
          sections: _generatePieChartSections(categoryTotals),
          centerSpaceRadius: 80,
          sectionsSpace: 0,
          borderData: FlBorderData(show: false),
        ),
      ),
    ),
  );
}


  Widget _buildEmptyPieChart() {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox(
        width: 100,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Color(0xFF283B41),
                value: 1.0,
              ),
            ],
            centerSpaceRadius: 40,
            sectionsSpace: 0,
          ),
        ),
      ),
    );
  }

 List<PieChartSectionData> _generatePieChartSections(
    Map<String, double> categoryTotals,
  ) {
    List<PieChartSectionData> sections = [];
    int index = 0;

    
    List<Color> pieColors = [
      Color(0xFF283B41),
      Color(0xFF3C525A),
      Color(0xFF4F676F),
      Color(0xFF617D86),
      Color(0xFF739399),
      Color(0xFF85A2AD),
    ];

    categoryTotals.forEach((category, total) {
      const double radius = 50;
      const double titleFontSize = 14;

      
      String labelText = '$category\n${_formatCurrency(total)}';
      sections.add(
        PieChartSectionData(
          color: pieColors[index % pieColors.length], 
          value: total,
          title: labelText,
          radius: radius,
          titlePositionPercentageOffset: 0.7,
          titleStyle: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white, 
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 4.0,
                color: Colors.black, 
              ),
            ],
          ),
        ),
      );
      index++;
    });
    return sections;
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
   String getMessageForIndex(int index) {
    switch (index) {
      case 0:
        return 'Showing first item';
      case 1:
        return 'Showing second item';
      case 2:
        return 'Showing third item';
      default:
        return '';
    }
  }
}
class BarChartWidget extends StatefulWidget {
  @override
  BarChartWidgetState createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  late Future<List<double>> _monthlySpendingFuture;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future<void> _updateData() async {
    setState(() {
      _monthlySpendingFuture = _calculateMonthlySpending();
    });
  }

  Future<List<double>> _calculateMonthlySpending() async {
    try {
      List<double> monthlySpending = [];
      DateTime now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        DateTime startDate = DateTime(now.year, now.month - i, 1);
        DateTime endDate = DateTime(now.year, now.month - i + 1, 0);
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        String startDateStr = formatter.format(startDate);
        String endDateStr = formatter.format(endDate);
        TransactionsDB transactionsDB = await DatabaseHelper().getTransactionsDatabase();
        List<Transaction> transactions = await transactionsDB.getTransactionsBetweenDates(startDateStr, endDateStr);
        double totalSpending = transactions.fold(0.0, (sum, transaction) => sum + transaction.transactionAmount);
        monthlySpending.add(totalSpending);
      }
      return monthlySpending.reversed.toList();
    } catch (e) {
      print('Error calculating monthly spending: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _monthlySpendingFuture,
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
          return _buildBarChart(snapshot.data!);
        } else {
          return Center(
            child: Text('No data available'),
          );
        }
      },
    );
  }

  Widget _buildBarChart(List<double> monthlySpending) {
    List<String> monthNames = _getMonthNames();

    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value) => const TextStyle(color: Color(0xff7589a2), fontSize: 14),
              margin: 20,
              getTitles: (double value) {
                int index = value.toInt();
                if (index >= 0 && index < monthNames.length) {
                  return monthNames[index];
                }
                return '';
              },
            ),
            leftTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlySpending.asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  y: value,
                  colors: [Color(0xFF4F676F)],
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<String> _getMonthNames() {
    List<String> monthNames = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthName = DateFormat('MMM').format(month);
      monthNames.add(monthName);
    }
    return monthNames.reversed.toList();
  }
}
