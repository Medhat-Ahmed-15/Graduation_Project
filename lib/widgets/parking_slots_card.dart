import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/parking_slots_grid.dart';

class ParkingSlotscard extends StatelessWidget {
  final bool _loadingSpinner;
  ParkingSlotscard(this._loadingSpinner);
  @override
  Widget build(BuildContext context) {
    //Just The container Layout
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), topRight: Radius.circular(50)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: _loadingSpinner == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ParkingSlotsGrid(),
      ),
    );
  }
}
