import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/parking_slots_grid.dart';

class ParkingSlotscard extends StatelessWidget {
  final bool _loadingSpinner;
  ParkingSlotscard(this._loadingSpinner);
  @override
  Widget build(BuildContext context) {
    //Just The container Layout
    return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Container(
          height: 530, //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.1)
          decoration: BoxDecoration(
            color: const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5.0,
                spreadRadius: 5,
                offset: Offset(0.7, 0.7),
              )
            ],
          ),
          child: _loadingSpinner == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ParkingSlotsGrid(),
        ));
  }
}
