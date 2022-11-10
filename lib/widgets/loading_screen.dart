import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: colorProviderObj.generalCardColor),
        child: Center(
          child:
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
