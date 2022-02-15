// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/models/argumentsPassedFromBookingScreen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FloatingCancelButton extends StatefulWidget {
  ArgumentsPassedFromBookingScreen resultAfterBooking;
  Function resetApp;
  bool showCancelButton;
  FloatingCancelButton(
      this.resultAfterBooking, this.resetApp, this.showCancelButton);

  @override
  State<FloatingCancelButton> createState() => _FloatingCancelButtonState();
}

class _FloatingCancelButtonState extends State<FloatingCancelButton> {
  @override
  Widget build(BuildContext context) {
    return widget.showCancelButton == true
        ? Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    //myDIalog is jaust prefix i made it while importing the libraries up
                    builder: (BuildContext context) => ProgressDialog(
                          message: 'Cancelling Request',
                        ));

                //switching availability
                widget.resultAfterBooking.pickedParkingSlotDetails
                    .switchAvailability(
                        Provider.of<AuthProvider>(context, listen: false).token,
                        'empty',
                        'empty',
                        'empty');

                //Deleting request
                await Provider.of<RequestParkingSlotDetailsProvider>(context,
                        listen: false)
                    .cancelRequest(context);

                Navigator.pop(context);

                Fluttertoast.showToast(
                    msg: 'Request cancelled',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 5,
                    backgroundColor:
                        const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                    textColor: Colors.white,
                    fontSize: 16.0);

                widget.resetApp();

                // setState(() {
                //   showCancelButton = false;
                // });
              },
              child: CircleAvatar(
                backgroundColor: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                child: Icon(
                  Icons.cancel,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                radius: 20.0,
              ),
            ),
          )
        : const Text('');
  }
}
