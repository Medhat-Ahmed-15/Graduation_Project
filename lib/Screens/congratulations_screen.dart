import 'package:graduation_project/Screens/saveMoney_screen.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CongratulationsScreen extends StatefulWidget {
  static const routeName = '/CongratulationsScreen';

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
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
              child: Image.asset('assets/images/congrats.png'),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              'Congratulations 👏',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Proud to have you with us We \nhope you enjoy it ♥',
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
                  SaveMoneyScreen.routeName,
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
