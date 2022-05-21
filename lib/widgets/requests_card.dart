import 'dart:math';
import 'dart:ui';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/models/parking_slot_blueprint.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class RequestsCardWidget extends StatefulWidget {
  RequestedParkingSlotDetailsBluePrint recordedParkingSlotDetails;
  String flag;

  RequestsCardWidget(this.recordedParkingSlotDetails, this.flag);

  @override
  State<RequestsCardWidget> createState() => _RequestsCardWidgetState();
}

class _RequestsCardWidgetState extends State<RequestsCardWidget> {
  bool expanded = false;
  bool loading = false;
  bool loadingCancel = false;
  bool loadingLeave = false;

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  Future<void> cancelrequest() async {
    setState(() {
      loadingCancel = true;
    });

    //switching availability
    switchParkingAvailability('empty', 'empty', 'empty',
        widget.recordedParkingSlotDetails.parkingSlotId);

    //Deleting request
    await RequestParkingSlotDetailsProvider.deleteRecordedRequestDetatils(
        widget.recordedParkingSlotDetails.requestId);

    await sendCancellationEmail(
        currentUserOnline.name,
        widget.recordedParkingSlotDetails.parkingSlotId,
        currentUserOnline.email);

    setState(() {
      loadingCancel = false;
    });
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
            color: colorProviderObj.genralBackgroundColor,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10.0,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7),
            ),
          ],
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
                    ' ${widget.recordedParkingSlotDetails.parkingAreaAddressName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: colorProviderObj.textColor),
                  ),
                ),
                Container(
                  child: Text(
                    'Slot id:  ${widget.recordedParkingSlotDetails.parkingSlotId}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  icon: (Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: colorProviderObj.generalCardColor,
                  )),
                )
              ],
            ),
          ),
          subtitle: AnimatedContainer(
            height: expanded == true
                ? widget.flag == 'Scheduled'
                    ? 270
                    : 200
                : 0,
            duration: Duration(milliseconds: 300),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Starting Date:',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.recordedParkingSlotDetails.startDateTime,
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text('Ending Date:',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(widget.recordedParkingSlotDetails.endDateTime,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text('Total Cost:',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${widget.recordedParkingSlotDetails.totalCost}\$',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text('Payment method:',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${widget.recordedParkingSlotDetails.paymentMethod}',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text('Status:',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${widget.recordedParkingSlotDetails.status}',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                widget.flag == 'Scheduled'
                    ? widget.recordedParkingSlotDetails.status == 'arrived'
                        ? Expanded(
                            child: FlatButton(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    color: colorProviderObj.generalCardColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  height: 90,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: loadingLeave == true
                                          ? Center(
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Leave',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                    ),
                                  )),
                              onPressed: () async {
                                setState(() {
                                  loadingLeave = true;
                                });
                                await initPaymentSheet(context,
                                    email: "example@gmail.com", amount: 200000);

                                setState(() {
                                  loadingLeave = false;
                                });
                              },
                            ),
                          )
                        : Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: FlatButton(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.redAccent,
                                            width: 1.5,
                                          ),
                                          color:
                                              colorProviderObj.generalCardColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        height: 90,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: loadingCancel == true
                                                ? Center(
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                          ),
                                        )),
                                    onPressed: cancelrequest,
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1.5,
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        height: 90,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: loading == true
                                                ? Center(
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: colorProviderObj
                                                            .textColor,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    'GoPark',
                                                    style: TextStyle(
                                                      color: colorProviderObj
                                                          .textColor,
                                                    ),
                                                  ),
                                          ),
                                        )),
                                    onPressed: () async {
                                      singleRecordedRequestDetailsId = widget
                                          .recordedParkingSlotDetails.requestId;
                                      setState(() {
                                        loading = true;
                                      });

                                      final pickedParkingSlotData =
                                          await Provider.of<
                                                      ParkingSlotsProvider>(
                                                  context,
                                                  listen: false)
                                              .fetchSingleParkingSlotData(widget
                                                  .recordedParkingSlotDetails
                                                  .parkingSlotId);

                                      pickedParkingSlot = pickedParkingSlotData;

                                      pickedParkingSlotLocation = Address(
                                          placeName: widget
                                              .recordedParkingSlotDetails
                                              .parkingAreaAddressName,
                                          latitude: pickedParkingSlot.latitude,
                                          longitude:
                                              pickedParkingSlot.longitude);

                                      await RequestParkingSlotDetailsProvider
                                          .updateRecordedRequest('on his way',
                                              singleRecordedRequestDetailsId);

                                      setState(() {
                                        loading = false;
                                      });

                                      Navigator.of(context).pushNamed(
                                          MapScreen.routeName,
                                          arguments: 'coming from tabs screen');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                    : const Text('')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
