import 'package:flutter/material.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/single_parking_slot.dart';
import 'package:provider/provider.dart';

class ParkingSlotsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final parkingSlotsList = Provider.of<ParkingSlotsProvider>(context).slots;

    return GridView.builder(
      padding: const EdgeInsets.all(30),
      itemCount: parkingSlotsList.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: parkingSlotsList[index],
        child: SingleParkingSlot(
          index,
          parkingSlotsList[index],
        ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 70,
          mainAxisSpacing: 50),
    );
  }
}
