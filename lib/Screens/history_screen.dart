import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = '/HistoryScreen';
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('History'),
    );
    return Scaffold(
      drawer: MainDrawer(),
      appBar: appBar,
      backgroundColor: colorProviderObj.generalCardColor,
      body: const Center(
        child: Text('History Screen'),
      ),
    );
  }
}
