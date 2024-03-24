library user.globals;
import 'carousel.dart';

String displayName = "";
String globalUserName = '';
String globalCurrency = 'GBP';
int globalUser = 0;
bool loggedIn = false;
bool remainLoggedIn = false;
int itemDisplayed = 0;

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