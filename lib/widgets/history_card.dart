import 'dart:ui';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class HistoryCardWidget extends StatelessWidget {
  RequestedParkingSlotDetailsBluePrint recordedParkingSlotDetails;

  HistoryCardWidget(this.recordedParkingSlotDetails);

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: colorProviderObj.genralBackgroundColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(10),
        child: ListTile(
          title: FittedBox(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    ' ${recordedParkingSlotDetails.parkingAreaAddressName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: colorProviderObj.textColor),
                  ),
                ),
                Container(
                  child: Text(
                    'Slot id:  ${recordedParkingSlotDetails.parkingSlotId}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Starting Date:',
                    style: TextStyle(
                        color: Colors.grey[500], fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    recordedParkingSlotDetails.startDateTime,
                    style: TextStyle(
                        color: Colors.grey[500], fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Ending Date:',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(recordedParkingSlotDetails.endDateTime,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Total Cost:',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text('${recordedParkingSlotDetails.totalCost}\$',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Payment method:',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text('${recordedParkingSlotDetails.paymentMethod}',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
