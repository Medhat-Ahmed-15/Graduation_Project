import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider with ChangeNotifier {
  Color generalCardColor = Colors.white;
  Color genralBackgroundColor = const Color.fromRGBO(236, 240, 241, 1);
  Color shadowColor = Colors.white;
  Color textColor = const Color.fromRGBO(23, 32, 42, 1);

  void switchToDarkThemeMode() {
    generalCardColor = const Color.fromRGBO(23, 32, 42, 1);
    genralBackgroundColor = const Color.fromRGBO(44, 62, 80, 1).withOpacity(1);
    shadowColor = Colors.black;
    textColor = Colors.white;
    notifyListeners();
  }

  void switchToLightThemeMode() {
    generalCardColor = Colors.white;
    genralBackgroundColor = const Color.fromRGBO(236, 240, 241, 1);
    shadowColor = Colors.white;
    textColor = const Color.fromRGBO(23, 32, 42, 1);
    notifyListeners();
  }

  Future<void> checkThemeMethodInThisScreen() async {
    final tunnelToStorage = await SharedPreferences.getInstance();

    if (!tunnelToStorage.containsKey('switchStatus')) {
      switchToLightThemeMode();
    }

    final extractedUserData =
        json.decode(tunnelToStorage.getString('switchStatus'))
            as Map<String, Object>;

    if (extractedUserData['status'] == true) {
      switchToDarkThemeMode();
    } else {
      switchToLightThemeMode();
    }
  }
}
