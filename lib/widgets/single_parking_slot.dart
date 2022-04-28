import 'package:dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/Screens/bookingSlotScreen.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:provider/provider.dart';

class SingleParkingSlot extends StatefulWidget {
  //according to this index i'm gonna decide wheather to make the box opened from left side or right side
  int index;

  ParkingSlotBlueprintProvider parkingSlotBlueprintProvider;

  List<String> recommendedSlotsIds;

  SingleParkingSlot(
      this.index, this.parkingSlotBlueprintProvider, this.recommendedSlotsIds);

  @override
  State<SingleParkingSlot> createState() => _SingleParkingSlotState();
}

class _SingleParkingSlotState extends State<SingleParkingSlot> {
  bool cancel = false;

  @override
  Widget build(BuildContext context) {
    //Designing the single parking slot box

    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 3.0,
              spreadRadius: 3,
              offset: Offset(0.2, 0.2),
            ),
          ],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              color: colorProviderObj.generalCardColor,
              image: widget.parkingSlotBlueprintProvider.availability == true
                  ?

                  // widget.parkingSlotBlueprintProvider.userId ==
                  //         Provider.of<AuthProvider>(context, listen: false)
                  //             .getUserID
                  //     ? const DecorationImage(
                  //         image: ExactAssetImage('assets/images/myCar.png'),
                  //         fit: BoxFit.contain,
                  //       )
                  //     :
                  const DecorationImage(
                      image: ExactAssetImage('assets/images/otherCars.png'),
                      //fit: BoxFit.fitHeight,
                    )
                  : const DecorationImage(
                      image: ExactAssetImage('assets/images/parkingSign.png'),
                      // fit: BoxFit.fitHeight,
                    ),
              border: Border(
                left:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
                bottom:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
                top:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
                right:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
            ),
            child: Stack(
              children: [
                //ID Text
                Container(
                  margin: EdgeInsets.all(5),
                  child: Align(
                    alignment: widget.index % 2 == 0
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: Text(
                      widget.parkingSlotBlueprintProvider.id,
                      style: TextStyle(
                          color: colorProviderObj.textColor,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                //VIP Text
                Container(
                  margin: EdgeInsets.all(5),
                  child: Align(
                    alignment: widget.index % 2 == 0
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: Text(
                      widget.parkingSlotBlueprintProvider.vip == true
                          ? 'VIP'
                          : '',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                //recommended logo
                widget.recommendedSlotsIds.contains("\"" +
                            widget.parkingSlotBlueprintProvider.id +
                            "\"") &&
                        widget.parkingSlotBlueprintProvider.availability ==
                            false
                    ? Container(
                        margin: EdgeInsets.all(5),
                        child: Align(
                          alignment: widget.index % 2 == 0
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: Text(
                            '👍',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 20),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (widget.parkingSlotBlueprintProvider.availability == false) {
          //go to bookingParkingSlotScreen
          print('I AM GOING TO BOOK NOW');

          pickedParkingSlot = widget.parkingSlotBlueprintProvider;

          Navigator.of(context).pushNamed(
            BookingSlotScreen.routeName,
          );
        }
        // else if (Provider.of<AuthProvider>(context, listen: false)
        //         .getUserID ==
        //     widget.parkingSlotBlueprintProvider.userId) {
        //   print('Showing my request Data');

        //   ChoiceDialog messageDialog = ChoiceDialog(
        //     dialogBackgroundColor: colorProviderObj.generalCardColor,
        //     buttonOkColor: Theme.of(context).primaryColor,
        //     title:
        //         'Your booked Slot: ${widget.parkingSlotBlueprintProvider.id}',
        //     titleColor: Theme.of(context).primaryColor,
        //     message:
        //         'Starting Date \n ${widget.parkingSlotBlueprintProvider.startDateTtime.toString()}\n\n Ending Date \n ${widget.parkingSlotBlueprintProvider.endDateTime.toString()}',
        //     messageColor: colorProviderObj.textColor,
        //     buttonOkText: 'Ok',
        //     dialogRadius: 15.0,
        //     buttonRadius: 18.0,
        //     buttonCancelText: 'Cancel Request',
        //     buttonOkOnPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //     buttonCancelOnPressed: () async {
        //       showDialog(
        //           context: context,
        //           //myDIalog is jaust prefix i made it while importing the libraries up
        //           builder: (BuildContext context) => myDialog.ProgressDialog(
        //                 message: 'Cancelling Request',
        //               ));

        //       //switching availability
        //       await widget.parkingSlotBlueprintProvider.switchAvailability(
        //           Provider.of<AuthProvider>(context, listen: false).token,
        //           'empty',
        //           'empty',
        //           'empty');
        //       //Deleting request
        //       await Provider.of<RequestParkingSlotDetailsProvider>(context,
        //               listen: false)
        //           .cancelRequest(context);

        //       Navigator.pop(context);

        //       Fluttertoast.showToast(
        //           msg: 'Request cancelled',
        //           toastLength: Toast.LENGTH_LONG,
        //           gravity: ToastGravity.BOTTOM,
        //           timeInSecForIosWeb: 5,
        //           backgroundColor:
        //               const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
        //           textColor: Colors.white,
        //           fontSize: 16.0);

        //       setState(() {});
        //     },
        //   );
        //   messageDialog.show(context, barrierColor: Colors.white);
        // }
        else {
          print('Showing others Data');

          // print(parkingSlotBlueprintProvider.availability);
          // print();
          // print(parkingSlotBlueprintProvider.id);
          // print(parkingSlotBlueprintProvider.latitude);
          // print(parkingSlotBlueprintProvider.longitude);
          // print(parkingSlotBlueprintProvider.userId);

          MessageDialog messageDialog = MessageDialog(
            dialogBackgroundColor: colorProviderObj.generalCardColor,
            buttonOkColor: Theme.of(context).primaryColor,
            title: 'Parking Slot: ${widget.parkingSlotBlueprintProvider.id}',
            titleColor: Theme.of(context).primaryColor,
            message:
                'Starting Date \n ${widget.parkingSlotBlueprintProvider.startDateTtime.toString()}\n\n Ending Date \n ${widget.parkingSlotBlueprintProvider.endDateTime.toString()}',
            messageColor: colorProviderObj.textColor,
            buttonOkText: 'Notify me when available',
            dialogRadius: 15.0,
            buttonRadius: 18.0,
            buttonOkOnPressed: () {
              //going to notify you here
            },
          );
          messageDialog.show(context, barrierColor: Colors.white);
        }
      },
    );
  }
}
