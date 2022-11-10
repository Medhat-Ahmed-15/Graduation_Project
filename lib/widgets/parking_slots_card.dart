import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/parking_slots_grid.dart';
import 'package:provider/provider.dart';

class ParkingSlotscard extends StatelessWidget {
  final bool _loadingSpinner;
  const ParkingSlotscard(this._loadingSpinner);
  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    //Just The container Layout
    return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Container(
          height: MediaQuery.of(context).size.height.round() <= 781 ? 450 : 530,
          decoration: BoxDecoration(
            color: colorProviderObj.genralBackgroundColor,
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
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ParkingSlotsGrid(),
                ),
        ));
  }
}
