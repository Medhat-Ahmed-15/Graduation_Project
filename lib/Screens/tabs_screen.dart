//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/tabs/history_tab.dart';
import 'package:graduation_project/tabs/scheduledRequests_tab.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs_screen';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  bool _isInit = true;
  ColorProvider colorProviderObj;

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
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: colorProviderObj.generalCardColor,
        drawer: MainDrawer(),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            children: const [
              Text(
                'Requests',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              //Expanded(child: Container()),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            isScrollable: true,
            labelPadding: const EdgeInsets.only(left: 65, right: 65),
            labelStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            unselectedLabelColor: Colors.grey[700],
            tabs: const [
              Tab(
                text: 'Scheduled',
                icon: Icon(Icons.schedule),
              ),
              Tab(
                text: 'History',
                icon: Icon(Icons.history),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScheduledRequestesTab(),
            HistoryTab(),
          ],
        ),
      ),
    );
  }
}
