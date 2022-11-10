// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class RecommendingAnotherSlotDialog extends StatefulWidget {
  //Function cancelrequest;
  String text;

  RecommendingAnotherSlotDialog(
    this.text,
  );

  @override
  State<RecommendingAnotherSlotDialog> createState() =>
      _RecommendingAnotherSlotDialogState();
}

class _RecommendingAnotherSlotDialogState
    extends State<RecommendingAnotherSlotDialog> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  bool loadingConfirm = false;
  bool loadingNextBookFree = false;

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: colorProviderObj.generalCardColor,
      elevation: 1.0,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorProviderObj.generalCardColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            Image.asset(
              'assets/images/sad.png',
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                    color: colorProviderObj.textColor),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        height: 50,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: loadingConfirm == true
                                ? Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: colorProviderObj.textColor,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        )),
                    onPressed: () async {
                      setState(() {
                        loadingConfirm = true;
                      });

                      var response =
                          await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();
                      String recordedRequestId =
                          response['singleRecordedRequestDetailsId'].toString();
                      String pickedSlotId =
                          response['pickedParkingSlotId'].toString();

                      //Remove Reserved Time From ParkingSlot
                      await removeReservedTimeFromParkingSlot(
                          currentUserId, pickedSlotId);

                      //Deleting request
                      await RequestParkingSlotDetailsProvider
                          .deleteRecordedRequestDetatils(recordedRequestId);

                      Address address = Address();
                      address.placeName = 'Alexandria Sporting Club';
                      address.placeId = 'ChIJdfXbQYnE9RQRhLHmynPh4PU';
                      address.latitude = 31.2127696;
                      address.longitude = 29.9333728;

                      pickedparkingSlotAreaLocation = address;

                      Navigator.of(context).pop();

                      Navigator.pushNamed(
                          mapScreenContext, ParkingSlotsScreen.routeName);

                      setState(() {
                        loadingConfirm = false;
                      });

                      Fluttertoast.showToast(
                          msg:
                              'Your old reservation has been deleted successfully',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor:
                              colorProviderObj.genralBackgroundColor,
                          textColor: colorProviderObj.textColor,
                          fontSize: 16.0);
                    },
                  ),
                  const SizedBox(
                    height: 15,
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
                        height: 50,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: loadingNextBookFree == true
                                ? Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Make my next rservation for free',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                          ),
                        )),
                    onPressed: () async {
                      setState(() {
                        loadingNextBookFree = true;
                      });

                      var response =
                          await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();
                      String recordedRequestId =
                          response['singleRecordedRequestDetailsId'].toString();
                      String pickedSlotId =
                          response['pickedParkingSlotId'].toString();

                      //Remove Reserved Time From ParkingSlot
                      await removeReservedTimeFromParkingSlot(
                          currentUserId, pickedSlotId);

                      //Deleting request
                      await RequestParkingSlotDetailsProvider
                          .deleteRecordedRequestDetatils(recordedRequestId);

                      await updateUserNextBookFree(true);

                      setState(() {
                        loadingNextBookFree = false;
                      });
                      Navigator.of(context).pop();

                      Fluttertoast.showToast(
                          msg:
                              'Your next reservation is saved to be on us successfully 💃',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor:
                              colorProviderObj.genralBackgroundColor,
                          textColor: colorProviderObj.textColor,
                          fontSize: 16.0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
