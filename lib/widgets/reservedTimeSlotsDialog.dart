// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/widgets/singleReservedTime_widget.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class ReservedTimeSlotsDialog extends StatefulWidget {
  @override
  State<ReservedTimeSlotsDialog> createState() =>
      _ReservedTimeSlotsDialogState();
}

class _ReservedTimeSlotsDialogState extends State<ReservedTimeSlotsDialog> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  List<DateTimeRange> data = [];
  bool reservationDatesIsNull = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (pickedParkingSlot.reservationDates != null) {
      reservationDatesIsNull = false;
      pickedParkingSlot.reservationDates.forEach((key, value) {
        Map<String, dynamic> nestedValue = value;

        nestedValue.forEach((key, value) {
          print(
              'Start Time: ${value['startingDateTime']} <*****************> End Time: ${value['endingDateTime']}');

          DateTime startDateTime =
              convertStringToDateTime(value['startingDateTime'].toString());

          DateTime endDateTime =
              convertStringToDateTime(value['endingDateTime'].toString());

          data.add(DateTimeRange(start: startDateTime, end: endDateTime));
        });
      });
    } else {
      reservationDatesIsNull = true;
    }
  }

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
          height: 500,
          decoration: BoxDecoration(
            color: colorProviderObj.generalCardColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: reservationDatesIsNull == true
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30.0),
                    Image.asset(
                      'assets/images/cactus.png',
                      width: 120.0,
                    ),
                    const SizedBox(height: 18.0),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'This Parking Slot Is\'nt Reserved From Anyone Yet ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: colorProviderObj.textColor),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    )
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Reserved Time Slots',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: colorProviderObj.textColor),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return SingleReservedTimeWidget(
                              data[index],
                            );
                          },
                          itemCount: data.length,
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}
