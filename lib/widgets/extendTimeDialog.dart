// ignore_for_file: file_names, unused_import

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:provider/provider.dart';

class ExtendTimeDialog extends StatefulWidget {
  int maxExtendingTime;
  DateTime prevEndDateTime;

  ExtendTimeDialog(this.maxExtendingTime, this.prevEndDateTime);

  @override
  State<ExtendTimeDialog> createState() => _ExtendTimeDialogState();
}

class _ExtendTimeDialogState extends State<ExtendTimeDialog> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  int counter = 0;
  bool succeefullExtending = false;

  FocusNode counterFocusNode = FocusNode();
  TextEditingController counterController = TextEditingController();

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorProviderObj.generalCardColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const SizedBox(
                //   height: 22.0,
                // ),
                const SizedBox(
                  height: 22.0,
                ),
                Text(
                  ' ${durationToString(widget.maxExtendingTime)} (Max)',
                  style: TextStyle(
                      color: colorProviderObj.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 22),
                ),
                const SizedBox(
                  height: 22.0,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/images/minus.png')),
                      onPressed: () {
                        setState(() {
                          counter--;
                          counterController.text = counter.toString();
                          if (counter < 0) {
                            counter = 0;
                          }
                        });
                      },
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: counterController,
                        onTap: () {
                          setState(() {});
                        },
                        focusNode: counterFocusNode,
                        style: TextStyle(color: colorProviderObj.textColor),
                        cursorColor: colorProviderObj.textColor,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: colorProviderObj.genralBackgroundColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    FlatButton(
                      child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/images/plus.png')),
                      onPressed: () {
                        setState(() {
                          counter++;
                          counterController.text = counter.toString();
                          if (counter > widget.maxExtendingTime) {
                            counter = widget.maxExtendingTime;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 22.0,
                ),
                succeefullExtending == true
                    ? SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset('assets/images/successfull.png'),
                      )
                    : FlatButton(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 52,
                          child: Align(
                            alignment: Alignment.center,
                            child: loading == true
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Confirm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        onPressed: () async {
                          if (int.parse(counterController.text) >
                              widget.maxExtendingTime) {
                            Fluttertoast.showToast(
                                msg:
                                    'The time you entered exceeds the maximum available extending time',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 5,
                                backgroundColor:
                                    colorProviderObj.genralBackgroundColor,
                                textColor: colorProviderObj.textColor,
                                fontSize: 16.0);
                          } else {
                            try {
                              setState(() {
                                loading = true;
                              });

                              AndroidAlarmManager.cancel(2);

                              var response =
                                  await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();
                              String recordedRequestId =
                                  response['singleRecordedRequestDetailsId']
                                      .toString();

                              String pickedSlotId =
                                  response['pickedParkingSlotId'].toString();

                              var prevEndDateTimeInString =
                                  await getEndingTimeReservedDate(
                                      currentUserId, pickedSlotId);

                              var prevEndDateTime = convertStringToDateTime(
                                  prevEndDateTimeInString);

                              DateTime updatedEndDateTime = prevEndDateTime.add(
                                  Duration(
                                      minutes:
                                          int.parse(counterController.text)));

                              await RequestParkingSlotDetailsProvider
                                  .updateEndTimeInRecordedRequest(
                                      updatedEndDateTime.toString(),
                                      recordedRequestId);

                              await updateEndingTimeReservedDate(
                                  updatedEndDateTime.toString(),
                                  currentUserId,
                                  pickedSlotId);

                              await AndroidAlarmManager.oneShotAt(
                                  DateTime(
                                      updatedEndDateTime.year,
                                      updatedEndDateTime.month,
                                      updatedEndDateTime.day,
                                      updatedEndDateTime.hour,
                                      updatedEndDateTime.minute + 2),
                                  2,
                                  getSensorDetectResultAfterEndingTime);

                              Navigator.of(context)
                                  .pushReplacementNamed(MapScreen.routeName);

                              Fluttertoast.showToast(
                                  msg:
                                      'Your ending time has successfully extended 👍',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor:
                                      colorProviderObj.genralBackgroundColor,
                                  textColor: colorProviderObj.textColor,
                                  fontSize: 16.0);

                              setState(() {
                                loading = false;
                              });
                            } catch (error) {
                              print(
                                  'Update EndTime In Recorded Request Error 2 :: $error');
                            }
                          }
                        },
                      ),
                const SizedBox(
                  height: 22.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
