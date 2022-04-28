import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/history_card.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/HistoryScreen';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var _isInit = true;
  bool _loadingSpinner = true;

  List<RequestedParkingSlotDetailsBluePrint> requestParkingSlotDetailsList;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });

      RequestParkingSlotDetailsProvider.fetchRecordedRequests().then((value) {
        requestParkingSlotDetailsList =
            Provider.of<RequestParkingSlotDetailsProvider>(context,
                    listen: false)
                .getRecordedrequetsList;
      }).then((value) => setState(() {
            _loadingSpinner = false;
          }));
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
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('History'),
    );
    return Scaffold(
      drawer: MainDrawer(),
      appBar: appBar,
      backgroundColor: colorProviderObj.generalCardColor,
      body: _loadingSpinner == true
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  return HistoryCardWidget(
                      requestParkingSlotDetailsList[index]);
                },
                itemCount: requestParkingSlotDetailsList.length,
              ),
            ),
    );
  }
}
