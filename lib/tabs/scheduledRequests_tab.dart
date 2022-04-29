// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/searchScreen.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/requests_card.dart';
import 'package:provider/provider.dart';

class ScheduledRequestesTab extends StatefulWidget {
  @override
  State<ScheduledRequestesTab> createState() => _ScheduledRequestesTabState();
}

class _ScheduledRequestesTabState extends State<ScheduledRequestesTab> {
  bool _isInit = true;
  bool _loadingSpinner = true;
  ColorProvider colorProviderObj;

  List<RequestedParkingSlotDetailsBluePrint>
      scheduledRequestParkingSlotDetailsList;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

      setState(() {
        _loadingSpinner = true;
      });

      RequestParkingSlotDetailsProvider.fetchRecordedRequests().then((value) {
        scheduledRequestParkingSlotDetailsList =
            RequestParkingSlotDetailsProvider.getScheduledRequestsList;

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
    return _loadingSpinner == true
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : scheduledRequestParkingSlotDetailsList == null ||
                scheduledRequestParkingSlotDetailsList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      width: 300,
                      height: 250,
                      child: Image.asset(
                        'assets/images/schedule.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'You haven\'t booked any parking slot yet',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                    FlatButton(
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                            color: colorProviderObj.generalCardColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 60,
                          width: 130,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Start booking',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          )),
                      onPressed: () {
                        Navigator.of(context).pushNamed(SearchScreen.routeName);
                      },
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemBuilder: (ctx, index) {
                  return RequestsCardWidget(
                      scheduledRequestParkingSlotDetailsList[index],
                      'Scheduled');
                },
                itemCount: scheduledRequestParkingSlotDetailsList.length,
              );
  }
}
