// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/models/argumentsPassedFromBookingScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ConfirmArrivalCard extends StatefulWidget {
  ArgumentsPassedFromBookingScreen resultAfterBooking;
  Function resetApp;
  ConfirmArrivalCard(this.resultAfterBooking, this.resetApp);

  @override
  State<ConfirmArrivalCard> createState() => _ConfirmArrivalCardState();
}

class _ConfirmArrivalCardState extends State<ConfirmArrivalCard> {
  bool loading;
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
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });

                      Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high);

                      LatLng latlngPosition =
                          LatLng(position.latitude, position.longitude);

                      String address = await Provider.of<AddressDataProvider>(
                              context,
                              listen: false)
                          .convertToReadableAddress(position);

                      setState(() {
                        loading = false;
                      });

                      Fluttertoast.showToast(
                          msg:
                              'Address: $address   Latitude: ${position.latitude}  Longitude: ${position.longitude}',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor:
                              colorProviderObj.genralBackgroundColor,
                          textColor: colorProviderObj.textColor,
                          fontSize: 16.0);
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
                    onPressed: () async {
                      //Cancel Request
                      showDialog(
                          context: context,
                          //myDIalog is jaust prefix i made it while importing the libraries up
                          builder: (BuildContext context) => ProgressDialog(
                                message: 'Cancelling Request',
                              ));

                      //switching availability
                      widget.resultAfterBooking.pickedParkingSlotDetails
                          .switchAvailability(
                              Provider.of<AuthProvider>(context, listen: false)
                                  .token,
                              'empty',
                              'empty',
                              'empty');

                      //Deleting request
                      await Provider.of<RequestParkingSlotDetailsProvider>(
                              context,
                              listen: false)
                          .cancelRequest(context);

                      Navigator.pop(context);

                      Fluttertoast.showToast(
                          msg: 'Request cancelled',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: const Color.fromRGBO(44, 62, 80, 1)
                              .withOpacity(1),
                          textColor: Colors.white,
                          fontSize: 16.0);

                      widget.resetApp();

                      // setState(() {
                      //   showCancelButton = false;
                      // });
                    },
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
