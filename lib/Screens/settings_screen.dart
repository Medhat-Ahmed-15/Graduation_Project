import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/SettingsScreen';
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSwitched = false;

  Future<void> toggleSwitch(bool value) async {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      Provider.of<ColorProvider>(context, listen: false)
          .switchToDarkThemeMode();

      final tunnelToStorage = await SharedPreferences.getInstance();

      final switchStatus = json.encode({
        'status': isSwitched,
      });

      tunnelToStorage.setString(
          'switchStatus', switchStatus); //this to write data

    } else {
      setState(() {
        isSwitched = false;
      });
      final tunnelToStorage = await SharedPreferences.getInstance();

      final switchStatus = json.encode({
        'status': isSwitched,
      });

      tunnelToStorage.setString(
          'switchStatus', switchStatus); //this to write data
    }
  }

  void checkSwitchStatusFromDeviceStorage() async {
    final tunnelToStorage = await SharedPreferences.getInstance();
    if (!tunnelToStorage.containsKey('switchStatus')) {
      setState(() {
        isSwitched = false;
      });
    }
    final extractedUserData =
        json.decode(tunnelToStorage.getString('switchStatus'))
            as Map<String, Object>;

    setState(() {
      isSwitched = extractedUserData['status'];
    });
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    checkSwitchStatusFromDeviceStorage();
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Settings'),
    );

    return Scaffold(
      drawer: MainDrawer(),
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorProviderObj.generalCardColor,
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: colorProviderObj.genralBackgroundColor,
                  ),
                  child: Column(children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/setting.png"),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w900,
                              color: colorProviderObj.textColor),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 2.0,
                        spreadRadius: 1,
                        offset: Offset(0.2, 0.2),
                      ),
                    ],
                    color: colorProviderObj.generalCardColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Theme',
                          style: TextStyle(
                              color: colorProviderObj.textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 20),
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: toggleSwitch,
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.red[200],
                          inactiveThumbColor: Theme.of(context).primaryColor,
                          inactiveTrackColor:
                              const Color.fromRGBO(44, 62, 80, 1)
                                  .withOpacity(1),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
