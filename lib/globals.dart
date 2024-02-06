
library user.globals;
String DisplayName = "";
String globalUserName = '';
String globalCurrency = 'GBP'; 
int globalUser = 0;
bool loggedIn = false;
bool remainLoggedIn = false;



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
  return globalUserName;
}

int getUserID(){
    return globalUser;
}

bool isLoggedIn(){
  return loggedIn;
}