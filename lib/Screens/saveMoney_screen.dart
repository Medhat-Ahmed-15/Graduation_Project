// ignore_for_file: file_names

import 'package:graduation_project/Screens/saveTime_screen%20.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SaveMoneyScreen extends StatefulWidget {
  static const routeName = '/SaveMoneyScreen';

  @override
  State<SaveMoneyScreen> createState() => _SaveMoneyScreenState();
}

class _SaveMoneyScreenState extends State<SaveMoneyScreen> {
  ColorProvider colorProviderObj;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);

    return Scaffold(
      backgroundColor: colorProviderObj.generalCardColor,
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()),
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset('assets/images/saveMoney.png'),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              'Save Your Money 💰',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Need to write something here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 82,
            ),
            FlatButton(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 50,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  SaveTimeScreen.routeName,
                );
              },
            ),
            const SizedBox(
              height: 7,
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
