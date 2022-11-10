// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/tabs_screen.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class SuccessfullyBookedDialog extends StatelessWidget {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: colorProviderObj.generalCardColor,
      elevation: 1.0,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorProviderObj.genralBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            Image.asset(
              'assets/images/check.png',
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'A confirmation mail was sent to you',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                    color: colorProviderObj.textColor),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Theme.of(context).primaryColor)),
              color: colorProviderObj.genralBackgroundColor,
              textColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(8.0),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(TabsScreen.routeName);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'View Request',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
    );
  }
}
