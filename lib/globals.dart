library user.globals;
import 'carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';

String displayName = "";
String globalUserName = '';
String globalCurrency = 'GBP';
int globalUser = 0;
bool loggedIn = false;
bool remainLoggedIn = false;
int itemDisplayed = 0;
double globalGoal = 0.00;

void resetUserGlobals() {
  globalUserName = '';
  globalCurrency = 'GBP';
  globalUser = 0;
  loggedIn = false;
}

void initializeUserGlobals(String userName, String currency) {
  globalUserName = userName;
  globalCurrency = currency;
}

String getDisplayName() {
  return displayName;
}

int getUserID() {
  return globalUser;
}

bool isLoggedIn() {
  return loggedIn;
}
Future<double> get globalBudget{
  return TransactionAnalyzer().calculateBudget();
}
Future<double> get globalSavings{
  return TransactionAnalyzer().getTotalSavings();
}
Future<double> globalGoalPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? storedGoal = prefs.getDouble('goal');
  if (storedGoal != null){
    return storedGoal;
  } else {
    
    return 0.00;
  }
}