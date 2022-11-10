// ignore_for_file: file_names

import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:graduation_project/widgets/confirmingCancellationDialog.dart';
import 'package:graduation_project/widgets/sensorDialog.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/confirmationDialog.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/verificationDialog.dart';
import 'package:provider/provider.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayer/audioplayer.dart';

class ConfirmArrivalCard extends StatefulWidget {
  Function resetApp;

  ConfirmArrivalCard(this.resetApp);

  @override
  State<ConfirmArrivalCard> createState() => _ConfirmArrivalCardState();
}

class _ConfirmArrivalCardState extends State<ConfirmArrivalCard> {
  bool loading;
  LatLongConverter converter = LatLongConverter();
  final audioPlayer = AudioPlayer();
  int counter = 0;

// Future setAudio()async {
//   final player=AudioCac

// }

  Future<void> confirmArraival(ColorProvider colorProviderObj) async {
    setState(() {
      loading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      loading = false;
    });

    final currentPosition = LatLng(position.latitude, position.longitude);
    final bookedSlotPosition =
        LatLng(pickedParkingSlot.latitude, pickedParkingSlot.longitude);

    print('My current lat in Confirm Arrival  $currentPosition');
    print('My current lng in Confirm Arrival  $bookedSlotPosition');

    double distance = SphericalUtil.computeDistanceBetween(
        currentPosition, bookedSlotPosition);

    // Fluttertoast.showToast(
    //     msg: 'Distance:  ${distance.toStringAsFixed(2)}',
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 5,
    //     backgroundColor:
    //         Provider.of<ColorProvider>(context, listen: false).textColor,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    print('Distance:  ${distance.toStringAsFixed(2)}');

    if (distance >= 0.0 && distance <= 1000.0) {
      print('arrived');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ConfirmationDialog(isLoading: true),
      );

      await Future.delayed(const Duration(seconds: 5));

      await RequestParkingSlotDetailsProvider.updateStatusInRecordedRequest(
          'arrived', singleRecordedRequestDetailsId);
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ConfirmationDialog(isLoading: false));

      widget.resetApp();
      await switchGate(pickedParkingSlot.id, 1);
      createNotification('Please note that your car is not parked correctly');

      Future.delayed(const Duration(seconds: 5)).then((value) {
        Timer.periodic(
          const Duration(seconds: 2),
          (timer) async {
            var response = await checkParkedCorrectly(pickedParkingSlot.id);

            if (response == false) {
              showDialog(
                  context: mapScreenContext,
                  barrierColor: Colors.transparent,
                  builder: (BuildContext context) => SensorDialog());

              audioPlayer.play(
                  'https://www.soundjay.com/misc/sounds/censor-beep-01.mp3');

              if (await Vibration.hasCustomVibrationsSupport()) {
                Vibration.vibrate();
              }
              counter++;
            } else {
              for (int i = 0; i < counter; i++) {
                Navigator.of(mapScreenContext).pop();
              }

              timer.cancel();
              Vibration.cancel();
              //Hna ha switch el availability ba3d maykoon rakn kowais w kol haga tmam
              //  await switchParkingAvailability(pickedParkingSlot.id);
              await switchGate(pickedParkingSlot.id, 0);
            }
          },
        );
      });

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate();
      }
    } else {
      Fluttertoast.showToast(
          msg:
              'You have to reach to your parking slot first before confirming arrival ❗',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: colorProviderObj.genralBackgroundColor,
          textColor: colorProviderObj.textColor,
          fontSize: 16.0);
    }
  }
//****************************************************************************************************************************************************************** */

  Future<void> cancelrequest() async {
    //Cancel Request
    showDialog(
        context: context,
        //myDIalog is jaust prefix i made it while importing the libraries up
        builder: (BuildContext context) => ProgressDialog(
              message: 'Cancelling Request',
            ));

    //Remove Reserved Time From ParkingSlot
    await removeReservedTimeFromParkingSlot(
        currentUserId, pickedParkingSlot.id);

    //Deleting request
    await RequestParkingSlotDetailsProvider.deleteRecordedRequestDetatils(
        singleRecordedRequestDetailsId);

    await AndroidAlarmManager.cancel(1);
    await AndroidAlarmManager.cancel(2);

    Navigator.pop(context);
    sendCancellationEmail(
        currentUserOnline.name, pickedParkingSlot.id, currentUserOnline.email);

    widget.resetApp();

    // setState(() {
    //   showCancelButton = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
          height: 300,
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
            //     const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.topRight,
            //   stops: [0, 1],
            // ),

            color: colorProviderObj.generalCardColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Center(
              child: Column(
                children: [
                  //Confirm Arrival button////////////////////////////////////////////////////////////////////////////////
                  Expanded(child: Container()),
                  FlatButton(
                    //the process of calling confirmArrival which in it calculating the distance is done after making sure that the verification code is entered correctly.. then I call confirm arrival inside verification dialog

                    onPressed: () async {
                      Fluttertoast.showToast(
                          msg: 'Please enter the code we sent to your email',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor:
                              colorProviderObj.genralBackgroundColor,
                          textColor: colorProviderObj.textColor,
                          fontSize: 16.0);
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) =>
                              VerificationDialog(confirmArraival));
                    },
                    child: Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10.0,
                            spreadRadius: 5,
                            offset: Offset(0.2, 0.2),
                          ),
                        ],
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: loading == true
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirm Arrival',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  //Close Icon//////////////////////////////////////////////////////////////////////////////////////////////
                  FlatButton(
                    //the process of calling confirmArrival which in it calculating the distance is done after making sure that the verification code is entered correctly.. then I call confirm arrival inside verification dialog

                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierColor: Colors.white24,
                          builder: (BuildContext context) =>
                              ConfirmingCancellationDialog(cancelrequest));
                    },
                    child: Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10.0,
                            spreadRadius: 5,
                            offset: Offset(0.2, 0.2),
                          ),
                        ],
                        color: colorProviderObj.generalCardColor,
                        border: Border.all(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel Request',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          )),
    );
  }
}
