import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/confirmingCancellationDialog.dart';
import 'package:graduation_project/widgets/extendTimeDialog.dart';
import 'package:graduation_project/widgets/ratingDialog.dart';
import 'package:graduation_project/widgets/sorryDialog.dart';
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
  bool loadingCamera = false;
  bool loadingExtendTime = false;

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  Future<void> cancelrequest() async {
    setState(() {
      loadingCancel = true;
    });

    //Remove Reserved Time From ParkingSlot
    await removeReservedTimeFromParkingSlot(
        currentUserId, widget.recordedParkingSlotDetails.parkingSlotId);

    //Deleting request
    await RequestParkingSlotDetailsProvider.deleteRecordedRequestDetatils(
        widget.recordedParkingSlotDetails.requestId);

    await AndroidAlarmManager.cancel(1);
    await AndroidAlarmManager.cancel(2);

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
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: colorProviderObj.generalCardColor,
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
                if (widget.recordedParkingSlotDetails.vip == true)
                  const SizedBox(
                    height: 10,
                  ),
                if (widget.recordedParkingSlotDetails.vip == true)
                  FlatButton(
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 22,
                      child: CircleAvatar(
                        radius: 21,
                        backgroundColor: colorProviderObj.generalCardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: loadingCamera == true
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : Image.asset('assets/images/viewCamera.png'),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        loadingCamera = true;
                      });
                      await LaunchApp.openApp(
                        androidPackageName: 'com.uniarch.mobile.phone',
                        iosUrlScheme: 'pulsesecure://',
                        appStoreLink:
                            'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
                        openStore: false,
                      );

                      setState(() {
                        loadingCamera = false;
                      });
                    },
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
                    color: colorProviderObj.genralBackgroundColor,
                  )),
                )
              ],
            ),
          ),
          subtitle: AnimatedContainer(
            height: expanded == true
                ? widget.flag == 'Scheduled'
                    ? 380
                    : 200
                : 0,
            duration: const Duration(milliseconds: 300),
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
                      Text(widget.recordedParkingSlotDetails.paymentMethod,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text('Vip Slot:',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${widget.recordedParkingSlotDetails.vip}',
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
                      Text(widget.recordedParkingSlotDetails.status,
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: loadingLeave == true
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
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
                                ),
                              ),
                              onPressed: () async {
                                DateTime startDateTime = DateTime(
                                  int.parse(widget
                                      .recordedParkingSlotDetails.startDateTime
                                      .split(' ')[0]
                                      .split('-')[0]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.startDateTime
                                      .split(' ')[0]
                                      .split('-')[1]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.startDateTime
                                      .split(' ')[0]
                                      .split('-')[2]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.startDateTime
                                      .split(' ')[1]
                                      .split(':')[0]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.startDateTime
                                      .split(' ')[1]
                                      .split(':')[1]),
                                );

                                print(
                                    'Start Date Time From Firebase::: $startDateTime');

                                print(
                                    'Current User Online CrossedLimit ${currentUserOnline.crossedLimit}');

                                int timeInMinutesBetween = DateTime.now()
                                    .difference(startDateTime)
                                    .inMinutes;
                                int totalCost = currentUserOnline
                                            .crossedLimit ==
                                        false
                                    ? (timeInMinutesBetween * (1 / 6)).round()
                                    : (timeInMinutesBetween * (5 / 12)).round();

                                setState(() {
                                  loadingLeave = true;
                                });
                                bool response;

                                if (currentUserOnline.nextBookFree == true) {
                                  response = true;
                                } else {
                                  response = await initPaymentSheet(context,
                                      email: currentUserOnline.email,
                                      amount: 100);

                                  // (int.parse(totalCost.toString() +
                                  //                 '00') +
                                  //             int.parse(
                                  //                 currentUserOnline
                                  //                         .penalty
                                  //                         .toString() +
                                  //                     '00')) <
                                  //         int.parse(1.toString() + '00')
                                  //     ? 1
                                  //     : int.parse(totalCost.toString() +
                                  //             '00') +
                                  //         int.parse(currentUserOnline
                                  //                 .penalty
                                  //                 .toString() +
                                  //             '00'));
                                }

                                if (response == true) {
                                  AndroidAlarmManager.cancel(1);
                                  singleRecordedRequestDetailsId = widget
                                      .recordedParkingSlotDetails.requestId;

                                  // await switchParkingAvailability(widget
                                  //     .recordedParkingSlotDetails
                                  //     .parkingSlotId);

                                  var response =
                                      await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();

                                  String pickedSlotId =
                                      response['pickedParkingSlotId']
                                          .toString();

                                  await removeReservedTimeFromParkingSlot(
                                      currentUserId,
                                      widget.recordedParkingSlotDetails
                                          .parkingSlotId);

                                  await RequestParkingSlotDetailsProvider
                                      .updateStatusInRecordedRequest('left',
                                          singleRecordedRequestDetailsId);

                                  await RequestParkingSlotDetailsProvider
                                      .updateCostInRecordedRequest(totalCost,
                                          singleRecordedRequestDetailsId);

                                  // ana ba access el user data 3ashan 2a5alee el penalty el 3and el user ba 0 3ashan how lama bay leave ba5aleeh yadf3 kol el 3aleih

                                  await chargeUsersPenaltyToZero();

                                  await changeUsersCrossedLimit(false);

                                  await updateUserNextBookFree(false);

                                  await switchGate(pickedSlotId, 1);

                                  if (currentUserOnline.nextBookFree == true) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Your reservation is free this time as we promised you 😊❤',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 5,
                                        backgroundColor: colorProviderObj
                                            .genralBackgroundColor,
                                        textColor: colorProviderObj.textColor,
                                        fontSize: 16.0);
                                  }

                                  setState(() {
                                    loadingLeave = false;
                                  });

                                  await Future.delayed(
                                      const Duration(seconds: 10));

                                  await switchGate(pickedParkingSlot.id, 0);

                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.white24,
                                    builder: (BuildContext context) =>
                                        RatingDialog(),
                                  );
                                }
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
                                                ? const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
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
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierColor: Colors.white24,
                                          builder: (BuildContext context) =>
                                              ConfirmingCancellationDialog(
                                                  cancelrequest));
                                    },
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
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: colorProviderObj
                                                            .textColor,
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'GoPark',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            'Yellowtail',
                                                        fontSize: 18),
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
                                          .updateStatusInRecordedRequest(
                                              'on his way',
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
                    : const Text(''),
                const SizedBox(
                  height: 14,
                ),
                widget.flag == 'Scheduled'
                    ? widget.recordedParkingSlotDetails.status == 'arrived'
                        ? Expanded(
                            child: FlatButton(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5,
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                height: 90,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: loadingExtendTime == true
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Extend Time',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                DateTime endDateTime = DateTime(
                                  int.parse(widget
                                      .recordedParkingSlotDetails.endDateTime
                                      .split(" ")[0]
                                      .split("-")[0]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.endDateTime
                                      .split(" ")[0]
                                      .split("-")[1]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.endDateTime
                                      .split(" ")[0]
                                      .split("-")[2]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.endDateTime
                                      .split(" ")[1]
                                      .split(":")[0]),
                                  int.parse(widget
                                      .recordedParkingSlotDetails.endDateTime
                                      .split(" ")[1]
                                      .split(":")[1]),
                                );

                                print('Date: $endDateTime');
                                setState(() {
                                  loadingExtendTime = true;
                                });
                                int response = await extendTime(
                                    widget.recordedParkingSlotDetails
                                        .parkingSlotId,
                                    endDateTime);

                                if (response < 30) {
                                  showDialog(
                                      context: context,
                                      barrierColor: Colors.white24,
                                      builder: (BuildContext context) =>
                                          SorryDialog(
                                              'Sorry there isn\'nt any available time to extend'));
                                } else {
                                  showDialog(
                                      barrierColor: Colors.black87,
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) =>
                                          ExtendTimeDialog(
                                              response, endDateTime));
                                }

                                setState(() {
                                  loadingExtendTime = false;
                                });
                              },
                            ),
                          )
                        : const Text('')
                    : const Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
