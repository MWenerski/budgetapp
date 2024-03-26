import 'package:budgetapp/main.dart';
import 'package:budgetapp/transactions.dart';
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

      List<Transaction> transactions = await transactionsDB
          .getTransactionsBetweenDates(startDateStr, endDateStr);

      transactions = transactions
          .where((transaction) => transaction.transactionType == "Expense")
          .toList();

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

  Future<Map<String, double>> getTransactionTotalsLast6Months() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month - 6, 1);

      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDateStr = formatter.format(startDate);
      String endDateStr = formatter.format(endDate);

      List<Transaction> transactions = await transactionsDB
          .getTransactionsBetweenDates(startDateStr, endDateStr);

      transactions = transactions
          .where((transaction) => transaction.transactionType == "Income")
          .toList();

      Map<String, double> monthlyIncome = {};

      for (Transaction transaction in transactions) {
        DateTime transactionDateTime = DateTime.parse(transaction.dateTime);
        String monthYear = DateFormat('MMM yyyy').format(transactionDateTime);
        double amount = transaction.transactionAmount;
        monthlyIncome[monthYear] = (monthlyIncome[monthYear] ?? 0.0) + amount;
      }
      return monthlyIncome;
    } catch (e) {
      print('Error getting monthly income: $e');
      rethrow;
    }
  }

  Future<double> calculateBudget() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 29));

      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDateStr = formatter.format(startDate);
      String endDateStr = formatter.format(endDate);

      TransactionsDB transactionsDB =
          await _databaseHelper.getTransactionsDatabase();
      List<Transaction> transactions = await transactionsDB
          .getTransactionsBetweenDates(startDateStr, endDateStr);

      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      for (Transaction transaction in transactions) {
        if (transaction.transactionType == "Income") {
          totalIncome += transaction.transactionAmount;
        } else if (transaction.transactionType == "Expense") {
          totalExpenses += transaction.transactionAmount;
        }
      }

      double availableBalance = totalIncome - totalExpenses;
      return availableBalance;
    } catch (e) {
      print('Error calculating budget: $e');
      rethrow;
    }
  }

Future<double> getTotalSavings() async {
  try {
    double totalSavings = 0.0;
    List<Transaction> savingsTransactions =
        await transactionsDB.getSavingsTransactions();
    for (Transaction transaction in savingsTransactions) {
      totalSavings += transaction.transactionAmount;
    }
    return double.parse(totalSavings.toStringAsFixed(2));
  } catch (e) {
    print('Error getting total savings: $e');
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
  final StackedBarChartWidget stackedBarChartWidget = StackedBarChartWidget();

  @override
  Widget build(BuildContext context) {
    return buildCarousel();
  }

  Widget buildCarousel() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return Container(
          padding:
              EdgeInsets.only(left: 22.0, right: 22.0, top: 55.0, bottom: 0.0),
          child: Transform.scale(
            scale: index == 2 ? 0.8 : 1.0,
            child: _buildCarouselItem(index),
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 1,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 10),
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    switch (index) {
      case 0:
        return pieChartWidget;
      case 1:
        return barChartWidget;
      case 2:
        return stackedBarChartWidget;
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
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: PieChart(
              PieChartData(
                sections: _generatePieChartSections(categoryTotals),
                centerSpaceRadius: 70,
                sectionsSpace: 4,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.transparent,
              child: Text(
                'Expenses from the last 30 days',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPieChart() {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox(
        width: 70,
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
      Color.fromARGB(255, 23, 34, 37),
      Color(0xFF283B41),
      Color(0xFF3C525A),
      Color(0xFF617D86),
      Color.fromARGB(255, 94, 146, 163),
      Color.fromARGB(255, 153, 153, 153),
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
        TransactionsDB transactionsDB =
            await DatabaseHelper().getTransactionsDatabase();
        List<Transaction> transactions = await transactionsDB
            .getTransactionsBetweenDates(startDateStr, endDateStr);
        double totalSpending = transactions.fold(
            0.0, (sum, transaction) => sum + transaction.transactionAmount);
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
      aspectRatio: 1,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) =>
                      const TextStyle(color: Color(0xff7589a2), fontSize: 14),
                  margin: 10,
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
                  showingTooltipIndicators: [],
                  barRods: [
                    BarChartRodData(
                      y: value,
                      width: 30,
                      borderRadius: BorderRadius.circular(4),
                      colors: [Color(0xFF4F676F)],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 15),
              color: Colors.transparent,
              child: Text(
                'Monthly Spending',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
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

class StackedBarChartWidget extends StatefulWidget {
  @override
  StackedBarChartWidgetState createState() => StackedBarChartWidgetState();
}

class StackedBarChartWidgetState extends State<StackedBarChartWidget> {
  final TransactionAnalyzer analyzer = TransactionAnalyzer();
  late Future<Map<String, double>> _monthlyIncomeFuture;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future<void> _updateData() async {
    setState(() {
      _monthlyIncomeFuture = analyzer.getTransactionTotalsLast6Months();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _monthlyIncomeFuture,
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
          return _buildStackedBarChart(snapshot.data!);
        } else {
          return Center(
            child: Text('No data available'),
          );
        }
      },
    );
  }

  Widget _buildStackedBarChart(Map<String, double> monthlyIncome) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) =>
                      const TextStyle(color: Color(0xff7589a2), fontSize: 16),
                  margin: 20,
                  rotateAngle: 90,
                  getTitles: (double value) {
                    int index = value.toInt();
                    final monthNames = monthlyIncome.keys.toList();
                    if (index >= 0 && index < monthNames.length) {
                      return monthNames[index];
                    }
                    return '';
                  },
                ),
                leftTitles: SideTitles(showTitles: false),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(monthlyIncome),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.transparent,
              child: Text(
                'Monthly Income',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(Map<String, double> monthlyIncome) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    monthlyIncome.forEach((monthYear, income) {
      final barRod = BarChartRodData(
        y: income,
        width: 30,
        borderRadius: BorderRadius.circular(4),
        colors: [Color(0xFF283B41)],
      );
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [barRod],
        ),
      );
      index++;
    });
    return barGroups;
  }
}
