import 'package:flutter/material.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/Screens/bookingSlotScreen.dart';
import 'package:graduation_project/models/parking_slot_blueprint.dart';
import 'package:provider/provider.dart';

class SingleParkingSlot extends StatefulWidget {
  //according to this index i'm gonna decide wheather to make the box opened from left side or right side
  int index;

  ParkingSlotBlueprint parkingSlotBlueprintProvider;

  SingleParkingSlot(this.index, this.parkingSlotBlueprintProvider);

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
          color: colorProviderObj.generalCardColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              color: colorProviderObj.generalCardColor,
              image: widget.parkingSlotBlueprintProvider.sensorDetect == true
                  ? const DecorationImage(
                      image: ExactAssetImage('assets/images/otherCars.png'),
                      //fit: BoxFit.fitHeight,
                    )
                  : recommendedId == widget.parkingSlotBlueprintProvider.id
                      ? const DecorationImage(
                          image:
                              ExactAssetImage('assets/images/recommended.png'),
                          //fit: BoxFit.fitHeight,
                        )
                      : const DecorationImage(
                          image: ExactAssetImage(
                              'assets/images/parkingSlotsArea.png'),
                          // fit: BoxFit.fitHeight,
                        ),
            ),
            child: Stack(
              children: [
                //ID Text
                Container(
                  margin: const EdgeInsets.all(5),
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
                  margin: const EdgeInsets.all(5),
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
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        // if (widget.parkingSlotBlueprintProvider.availability == false) {
        //go to bookingParkingSlotScreen
        print('I AM GOING TO BOOK NOW');

        pickedParkingSlot = widget.parkingSlotBlueprintProvider;

        Navigator.of(context).pushNamed(
          BookingSlotScreen.routeName,
        );
      },
    );
  }
}
