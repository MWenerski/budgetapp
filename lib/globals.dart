
library user.globals;

String globalUserName = '';
String globalCurrency = 'GBP'; 


void resetUserGlobals() {
  globalUserName = '';
  globalCurrency = 'GBP';
}

void initializeUserGlobals(String userName, String currency) {
  globalUserName = userName;
  globalCurrency = currency;
}


String getUserName() {
  return globalUserName;
}
