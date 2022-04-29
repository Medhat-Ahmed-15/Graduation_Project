// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/requests_card.dart';
import 'package:provider/provider.dart';

class HistoryTab extends StatefulWidget {
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool _isInit = true;
  bool _loadingSpinner = true;
  ColorProvider colorProviderObj;

  List<RequestedParkingSlotDetailsBluePrint>
      historyRequestParkingSlotDetailsList;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
      setState(() {
        _loadingSpinner = true;
      });

      RequestParkingSlotDetailsProvider.fetchRecordedRequests().then((value) {
        historyRequestParkingSlotDetailsList =
            RequestParkingSlotDetailsProvider.getHistoryRequestsListList;

        setState(() {
          _loadingSpinner = false;
        });
      });
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
    return _loadingSpinner == true
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : historyRequestParkingSlotDetailsList.isEmpty ||
                historyRequestParkingSlotDetailsList == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      width: 300,
                      height: 250,
                      child: Image.asset(
                        'assets/images/history.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Your history is empty',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemBuilder: (ctx, index) {
                  return RequestsCardWidget(
                      historyRequestParkingSlotDetailsList[index], 'History');
                },
                itemCount: historyRequestParkingSlotDetailsList.length,
              );
  }
}
