// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/argumentsPassedFromBookingScreen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/confirmationDialog.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/verificationDialog.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class ConfirmArrivalCard extends StatefulWidget {
  ArgumentsPassedFromBookingScreen resultAfterBooking;
  Function resetApp;
  Function cancelTheTimer;

  ConfirmArrivalCard(
      this.resultAfterBooking, this.resetApp, this.cancelTheTimer);

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

    LatLng latlngCurrentUserPosition =
        LatLng(position.latitude, position.longitude);

    print('My current lat in Confirm Arrival  ${position.latitude.toDouble()}');
    print(
        'My current lng in Confirm Arrival  ${position.longitude.toDouble()}');

    double distance = Geolocator.distanceBetween(
      position.latitude.toDouble(),
      position.longitude.toDouble(),
      30.889783,
      29.3835925,
    );

    Fluttertoast.showToast(
        msg: 'Distance:  ${distance.toStringAsFixed(2)}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor:
            Provider.of<ColorProvider>(context, listen: false).textColor,
        textColor: Colors.white,
        fontSize: 16.0);
    print('Distance:  ${distance.toStringAsFixed(2)}');

    if (distance >= 0.0 && distance <= 100.0) {
      print('arrived');
      widget.cancelTheTimer();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              ConfirmationDialog(isLoading: true));

      await Future.delayed(Duration(seconds: 15));

      await Provider.of<RequestParkingSlotDetailsProvider>(context,
              listen: false)
          .updateRecordedRequest('arrived');
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
    widget.resultAfterBooking.pickedParkingSlotDetails.switchAvailability(
        Provider.of<AuthProvider>(context, listen: false).token,
        'empty',
        'empty',
        'empty');

    //Deleting request
    await Provider.of<RequestParkingSlotDetailsProvider>(context, listen: false)
        .cancelRequest(Provider.of<RequestParkingSlotDetailsProvider>(context,
                listen: false)
            .getRecorderRequestId);

    Navigator.pop(context);
    sendCancellationEmail(
        currentUserOnline.name,
        widget.resultAfterBooking.pickedParkingSlotDetails.id,
        currentUserOnline.email);

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
