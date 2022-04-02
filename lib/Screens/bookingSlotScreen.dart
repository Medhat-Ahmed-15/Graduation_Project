// ignore_for_file: file_names
import 'dart:async';

import 'package:dialogs/dialogs/choice_dialog.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/models/argumentsPassedFromBookingScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/dividerWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:date_time_picker/date_time_picker.dart';

class BookingSlotScreen extends StatefulWidget {
  static const routeName = '/BookingSlotScreen';

  @override
  State<BookingSlotScreen> createState() => _BookingSlotScreenState();
}

class _BookingSlotScreenState extends State<BookingSlotScreen> {
  DateTime startingDate;
  TimeOfDay startingTime;
  DateTime endingDate;
  TimeOfDay endingTime;

  DateTime endDateTime;
  DateTime startDateTime;
  int totalCost;
  ParkingSlotBlueprintProvider pickedParkingSlotDetails;

  Timer cancelRequestTimer;

  void setDateValuesAftePicked(String flag, BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: false);
    showDatePicker(
      builder: (context, child) => Theme(
          data: ThemeData().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).primaryColor,
              onSurface: colorProviderObj.textColor,
            ),
            dialogBackgroundColor: colorProviderObj.generalCardColor,
          ),
          child: child),
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, 30),
      initialDate: DateTime.now(),
    ).then((pickedDate) {
      //this function will be called once the user choose the date

      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          if (flag == 'initialDate') {
            startingDate = pickedDate;
          } else if (flag == 'finalDate') {
            endingDate = pickedDate;
          }
        });
      }
    });
  }

  void setTimeValuesAftePicked(String flag, BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: false);
    showTimePicker(
      builder: (context, child) => Theme(
          data: ThemeData().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              surface: colorProviderObj.generalCardColor,
              onSurface: colorProviderObj.textColor,
            ),
          ),
          child: child),
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      //this function will be called once the user choose the date

      if (pickedTime == null) {
        return;
      } else {
        setState(() {
          if (flag == 'initialTime') {
            startingTime = pickedTime;
          } else if (flag == 'finalTime') {
            endingTime = pickedTime;
          }
        });
      }
    });
  }

  void requestAndUpdateBookingSlot(
      ParkingSlotBlueprintProvider pickedParkingSlotDetails) async {
    String startingDateAndTime = DateFormat.yMd().format(startingDate) +
        " " +
        startingTime.hour.toString() +
        ":" +
        startingTime.minute.toString();

    String endingDateAndTime = DateFormat.yMd().format(endingDate) +
        " " +
        endingTime.hour.toString() +
        ":" +
        endingTime.minute.toString();

    String addressName =
        Provider.of<AddressDataProvider>(context, listen: false)
            .currentPlacePredicted
            .main_text;

    Address destinationAddress = Address(
        placeName: addressName,
        latitude: pickedParkingSlotDetails.latitude,
        longitude: pickedParkingSlotDetails.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Booking your slot, PLease wait...',
            ));

    Provider.of<AddressDataProvider>(context, listen: false)
        .updateDestinationLocationAddress(destinationAddress);

    await pickedParkingSlotDetails.switchAvailability(
        Provider.of<AuthProvider>(context, listen: false).token,
        startingDateAndTime,
        endingDateAndTime,
        Provider.of<AuthProvider>(context, listen: false).getUserID);

    ArgumentsPassedFromBookingScreen obj = ArgumentsPassedFromBookingScreen(
        "returned after booking", pickedParkingSlotDetails);

    Navigator.of(context)
        .pushReplacementNamed(MapScreen.routeName, arguments: obj);

    await sendEmail(
        startingDate: startingDateAndTime,
        endingDate: endingDateAndTime,
        userName: currentUserOnline.name,
        slotId: pickedParkingSlotDetails.id,
        toEmail: currentUserOnline.email,
        areaName: Provider.of<AddressDataProvider>(context, listen: false)
            .currentPlacePredicted
            .main_text);

    Fluttertoast.showToast(
        msg: 'A confirmation mail was sent 📧',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor:
            Provider.of<ColorProvider>(context, listen: false).textColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void calculateCost() {
    int year = startingDate.year;
    int month = startingDate.month;

    int startingDay = startingDate.day;
    int endingDay = endingDate.day;

    int startingHour = startingTime.hour;
    int endingHour = endingTime.hour;

    int startingMinute = startingTime.minute;
    int endingMinute = endingTime.minute;

    startDateTime =
        DateTime(year, month, startingDay, startingHour, startingMinute);

    endDateTime = DateTime(year, month, endingDay, endingHour, endingMinute);

    int timeInMinutesBetween = endDateTime.difference(startDateTime).inMinutes;

    totalCost = ((timeInMinutesBetween / 60) * 0.5).round();
  }

  void saveParkingRequestDetails() async {
    String userId = Provider.of<AuthProvider>(context, listen: false).getUserID;
    String parkingAreaAddressName =
        Provider.of<AddressDataProvider>(context, listen: false)
            .currentPlacePredicted
            .main_text;
    String parkingSlotId = pickedParkingSlotDetails.id;
    int cost = totalCost;
    String initialtDateTime = startDateTime.toString();
    String finalDateTime = endDateTime.toString();

    Map destinationLocMap = {
      'latitude': pickedParkingSlotDetails.latitude.toString(),
      'longitude': pickedParkingSlotDetails.longitude.toString(),
    };

    await Provider.of<RequestParkingSlotDetailsProvider>(context, listen: false)
        .postRequestParkingDetails(
            userId: userId,
            parkingAreaAddressName: parkingAreaAddressName,
            destinationLocMap: destinationLocMap,
            endDateTime: finalDateTime,
            parkingSlotId: parkingSlotId,
            paymentMethod: 'visa',
            status: 'pending',
            startDateTime: initialtDateTime,
            totalCost: cost);
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Book your slot'),
    );

    pickedParkingSlotDetails = ModalRoute.of(context).settings.arguments
        as ParkingSlotBlueprintProvider;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
              //     Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.topRight,
              //   stops: [0, 1],
              // ),
              color: colorProviderObj.generalCardColor,
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: colorProviderObj.genralBackgroundColor,
                  ),
                  child: Column(children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/location.png"),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          Provider.of<AddressDataProvider>(context,
                                  listen: false)
                              .currentPlacePredicted
                              .main_text,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: colorProviderObj.textColor),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Slot Id: ' + pickedParkingSlotDetails.id,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 15),
                    )
                  ]),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                child: Center(
                  child: Text(
                    'Pick your initial Date and Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorProviderObj.textColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              //**INITIAL DATE AND TIME/////////////////////////////////////////////////////////////////////////////////////////////////////////////

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/calendar.png',
                      height: 40.0,
                      width: 40.0,
                    ),

                    //initial Date****************
                    FlatButton(
                      onPressed: () {
                        setDateValuesAftePicked('initialDate', context);
                      },
                      child: Container(
                        width: 110,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            color: colorProviderObj.genralBackgroundColor
                                .withOpacity(1),
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    startingDate == null
                                        ? 'Initial Date'
                                        : DateFormat.yMd().format(startingDate),
                                    style: TextStyle(
                                        color: colorProviderObj.textColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/clock.png',
                      height: 50.0,
                      width: 50.0,
                    ),
                    //initial Time****************
                    FlatButton(
                      onPressed: () {
                        setTimeValuesAftePicked('initialTime', context);
                      },
                      child: Container(
                        width: 110,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            color: colorProviderObj.genralBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    startingTime == null
                                        ? 'Initial Time'
                                        : startingTime.hour.toString() +
                                            ":" +
                                            startingTime.minute.toString(),
                                    style: TextStyle(
                                        color: colorProviderObj.textColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                height: 2,
                width: 300,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 2.0,
                      spreadRadius: 1,
                      offset: Offset(0.2, 0.2),
                    ),
                  ],
                  color: colorProviderObj.generalCardColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              //**FINAL DATE AND TIME/////////////////////////////////////////////////////////////////////////////////////////////////////////////
              const SizedBox(
                height: 25,
              ),
              Container(
                child: Center(
                  child: Text(
                    'Pick your final Date and Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorProviderObj.textColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/calendar.png',
                      height: 40.0,
                      width: 40.0,
                    ),

                    //Final Date****************
                    FlatButton(
                      onPressed: () {
                        setDateValuesAftePicked('finalDate', context);
                      },
                      child: Container(
                        width: 110,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            color: colorProviderObj.genralBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    endingDate == null
                                        ? 'Final Date'
                                        : DateFormat.yMd().format(endingDate),
                                    style: TextStyle(
                                        color: colorProviderObj.textColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/clock.png',
                      height: 50.0,
                      width: 50.0,
                    ),
                    //FInal Time****************
                    FlatButton(
                      onPressed: () {
                        setTimeValuesAftePicked('finalTime', context);
                      },
                      child: Container(
                        width: 110,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            color: colorProviderObj.genralBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    endingTime == null
                                        ? 'Final Time'
                                        : endingTime.hour.toString() +
                                            ":" +
                                            endingTime.minute.toString(),
                                    style: TextStyle(
                                        color: colorProviderObj.textColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                height: 2,
                width: 300,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 2.0,
                      spreadRadius: 1,
                      offset: Offset(0.2, 0.2),
                    ),
                  ],
                  color: colorProviderObj.generalCardColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),

              //**BOOKING BUTTON/////////////////////////////////////////////////////////////////////////////////////////////////////////////

              const SizedBox(
                height: 70,
              ),

              FlatButton(
                onPressed: () {
                  calculateCost();

                  final choice = ChoiceDialog(
                    dialogBackgroundColor: colorProviderObj.generalCardColor,
                    title: 'Total Cost: $totalCost EG',
                    titleColor: Theme.of(context).primaryColor,
                    message:
                        'Starting Date \n ${startingDate.year}/${startingDate.month}/${startingDate.day} - ${startingTime.hour}:${startingTime.minute}\n\n Ending Date \n ${endingDate.year}/${endingDate.month}/${endingDate.day} - ${endingTime.hour}:${endingTime.minute}',
                    messageColor: colorProviderObj.textColor,
                    buttonOkText: 'Confirm',
                    buttonOkOnPressed: () {
                      requestAndUpdateBookingSlot(pickedParkingSlotDetails);
                      saveParkingRequestDetails();
                    },
                  );
                  choice.show(context, barrierColor: Colors.white);
                  //;
                },
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 10.0,
                        spreadRadius: 5,
                        offset: Offset(0.2, 0.2),
                      ),
                    ],
                    color: colorProviderObj.genralBackgroundColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Book parking slot',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
