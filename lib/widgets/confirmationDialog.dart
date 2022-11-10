// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class ConfirmationDialog extends StatelessWidget {
  bool isLoading;

  ConfirmationDialog({this.isLoading});

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
              isLoading == true
                  ? 'assets/images/wait.png'
                  : 'assets/images/check.png',
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            Text(
              isLoading == true ? 'Confirming arrival' : 'Confirmed arrival',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                  color: colorProviderObj.textColor),
            ),
            const SizedBox(
              height: 10.0,
            ),
            isLoading == true
                ? LinearProgressIndicator(
                    backgroundColor: colorProviderObj.genralBackgroundColor,
                    color: Theme.of(context).primaryColor,
                  )
                : FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    color: colorProviderObj.genralBackgroundColor,
                    textColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Ok'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
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
