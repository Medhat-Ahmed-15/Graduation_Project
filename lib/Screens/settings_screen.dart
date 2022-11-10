import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/auth_provider.dart';
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
  bool _saveLoadinfSpinner = false;

  FocusNode nameFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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

  //update User Data Method*********************************************************

  Future<void> updateUserData(AuthProvider authProviderObj) async {
    try {
      String updatedAddress = addressController.text == ""
          ? currentUserOnline.address
          : addressController.text;

      String updatedPhone = phoneController.text == ""
          ? currentUserOnline.phoneNumber
          : phoneController.text;

      String updatedName = nameController.text == ""
          ? currentUserOnline.name
          : nameController.text;

      setState(() {
        _saveLoadinfSpinner = true;
      });
      await authProviderObj.updateUserData(
          updatedName, updatedAddress, updatedPhone);

      setState(() {
        _saveLoadinfSpinner = false;
      });
    } on SocketException {
      Fluttertoast.showToast(
          msg: 'Updating Data Failed, Please Check Your Internet Connection',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor:
              Provider.of<ColorProvider>(context, listen: false).textColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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
    final authProviderObj = Provider.of<AuthProvider>(context);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Settings'),
      actions: [
        _saveLoadinfSpinner == true
            ? Container(
                margin: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(color: Colors.white))
            : IconButton(
                onPressed: () async {
                  await updateUserData(authProviderObj);
                },
                icon: const Icon(Icons.save))
      ],
    );

    return Scaffold(
      backgroundColor: colorProviderObj.generalCardColor,
      drawer: MainDrawer(),
      appBar: appBar,
      body: Stack(
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: 150.0,
              decoration: BoxDecoration(
                color: colorProviderObj.genralBackgroundColor,
              ),
              child: Column(children: [
                Expanded(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset("assets/images/setting.png"),
                  ),
                ),
                Expanded(
                  child: Container(
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
                ),
              ]),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(top: 200),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                                activeTrackColor:
                                    const Color.fromRGBO(44, 62, 80, 1)
                                        .withOpacity(1),
                                inactiveThumbColor:
                                    Theme.of(context).primaryColor,
                                inactiveTrackColor:
                                    const Color.fromRGBO(236, 240, 241, 1)
                                        .withOpacity(1),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: nameController,
                            onTap: () {
                              setState(() {});
                            },
                            focusNode: nameFocusNode,
                            style: TextStyle(color: colorProviderObj.textColor),
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: nameFocusNode.hasFocus
                                    ? Theme.of(context).primaryColor
                                    : colorProviderObj.genralBackgroundColor,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        colorProviderObj.genralBackgroundColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              hintText: currentUserOnline.name,
                              hintStyle:
                                  TextStyle(color: colorProviderObj.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: addressController,
                            onTap: () {
                              setState(() {});
                            },
                            focusNode: addressFocusNode,
                            style: TextStyle(color: colorProviderObj.textColor),
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.home,
                                color: addressFocusNode.hasFocus
                                    ? Theme.of(context).primaryColor
                                    : colorProviderObj.genralBackgroundColor,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        colorProviderObj.genralBackgroundColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              hintText: currentUserOnline.address,
                              hintStyle:
                                  TextStyle(color: colorProviderObj.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: phoneController,
                            onTap: () {
                              setState(() {});
                            },
                            focusNode: phoneFocusNode,
                            style: TextStyle(color: colorProviderObj.textColor),
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.home,
                                color: phoneFocusNode.hasFocus
                                    ? Theme.of(context).primaryColor
                                    : colorProviderObj.genralBackgroundColor,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        colorProviderObj.genralBackgroundColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              hintText: currentUserOnline.phoneNumber,
                              hintStyle:
                                  TextStyle(color: colorProviderObj.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: colorProviderObj.generalCardColor,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Icon(
                                Icons.badge,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                currentUserOnline.id,
                                style: TextStyle(
                                    color: colorProviderObj.textColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: colorProviderObj.generalCardColor,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Icon(
                                Icons.email_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                currentUserOnline.email,
                                style: TextStyle(
                                    color: colorProviderObj.textColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: colorProviderObj.generalCardColor,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  'You Have Violated The Terms And Conditions ${currentUserOnline.wrongUse}/10 Times',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: colorProviderObj.generalCardColor,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  'Next reservation for free: ${currentUserOnline.nextBookFree}',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
