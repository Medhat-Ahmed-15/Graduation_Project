// ignore_for_file: file_names, missing_return

import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/models/placePridictions.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  PlacePredictions currentPlacePredicted;

  PredictionTile({Key key, this.currentPlacePredicted}) : super(key: key);

  void showToast(String message, BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: colorProviderObj.genralBackgroundColor,
        textColor: colorProviderObj.textColor,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return FlatButton(
      onPressed: () async {
        var result =
            await Provider.of<AddressDataProvider>(context, listen: false)
                .getParkingAreaDetails(currentPlacePredicted.place_id, context);

        if (result == 'Alexandria Sporting Club' ||
            result == 'Smouha Sporting Club') {
          Navigator.of(context)
              .pushReplacementNamed(ParkingSlotsScreen.routeName);

          Provider.of<AddressDataProvider>(context, listen: false)
              .updateThePredictedPlaceAfterItIsPicked(currentPlacePredicted);
        } else if (result == 'failed') {
          showToast(
              "Something went wrong, Please check you internet connection and try again",
              context);
          FocusManager.instance.primaryFocus?.unfocus();
        } else {
          showToast("GoPark isn't available in this area yet", context);
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Container(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(
                  Icons.add_location,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        currentPlacePredicted.main_text,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        currentPlacePredicted.secondary_text,
                        style: TextStyle(
                            fontSize: 12.0, color: colorProviderObj.textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
      )),
    );
  }
}
