import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/auth_screen.dart';
import 'package:graduation_project/Screens/bookingSlotScreen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:provider/provider.dart';

class SingleParkingSlot extends StatelessWidget {
  //according to this index i'm gonna decide wheather to make the box opened from left side or right side
  int index;
  ParkingSlotBlueprintProvider parkingSlotBlueprintProvider;

  SingleParkingSlot(this.index, this.parkingSlotBlueprintProvider);
  @override
  Widget build(BuildContext context) {
    //Designing the single parking slot box
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
              color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
              image: parkingSlotBlueprintProvider.availability == true
                  ? parkingSlotBlueprintProvider.userId ==
                          Provider.of<AuthProvider>(context, listen: false)
                              .getUserID
                      ? const DecorationImage(
                          image: ExactAssetImage('assets/images/myCar.png'),
                          fit: BoxFit.contain,
                        )
                      : const DecorationImage(
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
            child: Container(
              margin: EdgeInsets.all(5),
              child: Align(
                alignment:
                    index % 2 == 0 ? Alignment.topRight : Alignment.topLeft,
                child: Text(
                  parkingSlotBlueprintProvider.id,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      ),

      // child: Container(
      //   height: 5,
      //   width: 50,
      //   decoration: BoxDecoration(
      //     image: parkingSlotBlueprintProvider.availability == true
      //         ? parkingSlotBlueprintProvider.userId ==
      //                 Provider.of<AuthProvider>(context, listen: false)
      //                     .getUserID
      //             ? const DecorationImage(
      //                 image: ExactAssetImage('assets/images/myCar.png'),
      //                 //fit: BoxFit.fitHeight,
      //               )
      //             : const DecorationImage(
      //                 image: ExactAssetImage('assets/images/otherCars.png'),
      //                 //fit: BoxFit.fitHeight,
      //               )
      //         : const DecorationImage(
      //             image: ExactAssetImage('assets/images/parkingSign.png'),
      //             // fit: BoxFit.fitHeight,
      //           ),
      //     border: Border(
      //       left: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      //       bottom: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      //       top: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      //       right: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      //     ),
      //   ),
      //   child: Container(
      //     margin: EdgeInsets.all(5),
      //     child: Align(
      //       alignment: index % 2 == 0 ? Alignment.topRight : Alignment.topLeft,
      //       child: Text(
      //         parkingSlotBlueprintProvider.id,
      //         style: TextStyle(
      //             color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
      //             fontWeight: FontWeight.w900),
      //       ),
      //     ),
      //   ),
      // ),
      onTap: () {
        if (Provider.of<AuthProvider>(context, listen: false).getUserID ==
                parkingSlotBlueprintProvider.userId ||
            parkingSlotBlueprintProvider.availability == false) {
          //go to bookingParkingSlotScreen
          print('I AM GOING TO BOOK NOW');

          Navigator.of(context).pushNamed(BookingSlotScreen.routeName,
              arguments: parkingSlotBlueprintProvider);
        } else {
          print('Showing Data');

          // print(parkingSlotBlueprintProvider.availability);
          // print(parkingSlotBlueprintProvider.endDateTime);
          // print(parkingSlotBlueprintProvider.id);
          // print(parkingSlotBlueprintProvider.latitude);
          // print(parkingSlotBlueprintProvider.longitude);
          // print(parkingSlotBlueprintProvider.startDateTtime);
          // print(parkingSlotBlueprintProvider.userId);
        }
      },
    );
  }
}
