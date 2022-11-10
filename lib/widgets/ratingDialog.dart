// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class RatingDialog extends StatefulWidget {
  //Function cancelrequest;
  // String text;

  // RatingDialog(
  //   this.text,
  // );

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  bool showSubmitbutton = false;

  double finalRating = 0.0;

  bool loading = false;

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
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            Image.asset(
              'assets/images/rate.png',
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'How was our service ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                    color: colorProviderObj.textColor),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            RatingBar.builder(
              initialRating: 0,
              itemPadding: const EdgeInsets.symmetric(horizontal: 5),
              itemSize: 50,
              itemCount: 5,
              // ignore: missing_return
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return const Icon(
                      Icons.sentiment_very_dissatisfied_sharp,
                      color: Colors.red,
                    );
                  case 1:
                    return const Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.redAccent,
                    );
                  case 2:
                    return const Icon(
                      Icons.sentiment_neutral,
                      color: Colors.amber,
                    );
                  case 3:
                    return const Icon(
                      Icons.sentiment_satisfied_alt_sharp,
                      color: Colors.lightGreen,
                    );
                  case 4:
                    return const Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.green,
                    );
                }
              },

              onRatingUpdate: (rating) {
                finalRating = rating;
                print('Rating:' " " + rating.toString());

                if (rating >= 1 && rating < 2) {
                  setState(() {
                    showSubmitbutton = true;
                  });
                }
              },
            ),
            const SizedBox(
              height: 15.0,
            ),
            if (showSubmitbutton == true)
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
                        child: loading == true
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
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    )),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });

                  await updateUserRating(finalRating.toString());
                  await RequestParkingSlotDetailsProvider
                      .updateRateInRecordedRequest(finalRating.toString(),
                          singleRecordedRequestDetailsId);
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacementNamed(MapScreen.routeName);

                  setState(() {
                    loading = false;
                  });
                },
              ),
            const SizedBox(height: 18.0),
          ],
        ),
      ),
    );
  }
}
