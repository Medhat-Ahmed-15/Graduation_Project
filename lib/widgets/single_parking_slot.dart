import 'package:flutter/material.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:provider/provider.dart';

class SingleParkingSlot extends StatelessWidget {
  //according to this index i'm gonna decide wheather to make the box opened from left side or right side
  int index;
  ParkingSlotBlueprintProvider parkingSlotBlueprintPrivider;
  SingleParkingSlot(this.index, this.parkingSlotBlueprintPrivider);
  @override
  Widget build(BuildContext context) {
    final parkingSlotBlueprintPrividerObj =
        Provider.of<ParkingSlotBlueprintProvider>(context);
    final authProviderObj = Provider.of<AuthProvider>(context);

    //Designing the single parking slot box
    return GestureDetector(
      child: Container(
        height: 5,
        width: 50,
        decoration: BoxDecoration(
          image: parkingSlotBlueprintPrivider.availability == true
              ? const DecorationImage(
                  image: ExactAssetImage('assets/images/car.png'),
                  fit: BoxFit.fitHeight,
                )
              : null,
          border: Border(
              left: index % 2 == 0
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 15)
                  : BorderSide(color: Colors.white, width: 0),
              bottom: BorderSide(color: Colors.pink[200], width: 5),
              top: BorderSide(color: Colors.pink[200], width: 5),
              right: index % 2 == 0
                  ? BorderSide(color: Colors.white, width: 0)
                  : BorderSide(
                      color: Theme.of(context).primaryColor, width: 15)),
        ),
      ),
      onTap: () {
        parkingSlotBlueprintPrividerObj
            .switchAvailability(authProviderObj.token);
      },
    );
  }
}
