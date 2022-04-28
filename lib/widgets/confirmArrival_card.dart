// ignore_for_file: file_names

import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/auth_provider.dart';
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

class ConfirmArrivalCard extends StatefulWidget {
  String flag;
  Function resetApp;
  Function cancelTheTimer;

  ConfirmArrivalCard(this.flag, this.resetApp, this.cancelTheTimer);

  @override
  State<ConfirmArrivalCard> createState() => _ConfirmArrivalCardState();
}

class _ConfirmArrivalCardState extends State<ConfirmArrivalCard> {
  bool loading;
  LatLongConverter converter = LatLongConverter();

  //**************************************************************************************************************************************************************** */

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

    if (distance >= 0.0 && distance <= 100.0) {
      print('arrived');
      widget.cancelTheTimer();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ConfirmationDialog(isLoading: true));

      await Future.delayed(Duration(seconds: 5));

      await RequestParkingSlotDetailsProvider.updateRecordedRequest('arrived');
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ConfirmationDialog(isLoading: false));

      widget.resetApp();
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

    //switching availability
    pickedParkingSlot.switchAvailability(
        Provider.of<AuthProvider>(context, listen: false).token,
        'empty',
        'empty',
        'empty');

    //Deleting request
    await RequestParkingSlotDetailsProvider.cancelRequest();

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
                        color: colorProviderObj.genralBackgroundColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: loading == true
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Text(
                                'Confirm Arrival',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  //Close Icon//////////////////////////////////////////////////////////////////////////////////////////////
                  FlatButton(
                    onPressed: cancelrequest,
                    child: CircleAvatar(
                      backgroundColor: colorProviderObj.genralBackgroundColor,
                      child: Icon(
                        Icons.cancel,
                        size: 70,
                        color: Theme.of(context).primaryColor,
                      ),
                      radius: 40.0,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Cancel Request',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
