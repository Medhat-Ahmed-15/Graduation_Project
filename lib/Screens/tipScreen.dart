// ignore_for_file: file_names

import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class TipScreen extends StatefulWidget {
  static const routeName = '/TipScreen';

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  ColorProvider colorProviderObj;
  bool _isInit = true;
  String flag;

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
    flag = ModalRoute.of(context).settings.arguments as String;
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
              child: Image.asset('assets/images/recommended.png'),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              'Tip',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'A parking slot with this logo in it indicates that it\'s recommended for you',
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
                Navigator.pushNamedAndRemoveUntil(
                    context, MapScreen.routeName, (route) => false);
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
