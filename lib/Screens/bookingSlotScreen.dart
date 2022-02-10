// ignore_for_file: file_names
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/dividerWidget.dart';
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

  void setDateValuesAftePicked(String flag) {
    showDatePicker(
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

  void setTimeValuesAftePicked(String flag) {
    showTimePicker(
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

  void requestBookingSlot(
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

    Address address = Address(
        placeName: addressName,
        latitude: pickedParkingSlotDetails.latitude,
        longitude: pickedParkingSlotDetails.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Booking your slot, PLease wait...',
            ));

    await pickedParkingSlotDetails.switchAvailability(
        Provider.of<AuthProvider>(context, listen: false).token);

    await Provider.of<ParkingSlotsProvider>(context, listen: false)
        .updateParkingSlot(
            pickedParkingSlotDetails.id, pickedParkingSlotDetails);

    Provider.of<AddressDataProvider>(context, listen: false)
        .updateDropOffLocationAddress(address);

    Navigator.of(context).pushReplacementNamed(MapScreen.routeName,
        arguments: 'returned after booking');
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Book your slot'),
    );

    var pickedParkingSlotDetails = ModalRoute.of(context).settings.arguments
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
              color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
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
                          style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
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
                child: const Center(
                  child: Text(
                    'Pick your initial Date and Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
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
                        setDateValuesAftePicked('initialDate');
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
                            color: const Color.fromRGBO(23, 32, 42, 1)
                                .withOpacity(1),
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    startingDate == null
                                        ? 'Initial Date'
                                        : DateFormat.yMd().format(startingDate),
                                    style:
                                        const TextStyle(color: Colors.white)),
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
                        setTimeValuesAftePicked('initialTime');
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
                            color: const Color.fromRGBO(23, 32, 42, 1)
                                .withOpacity(1),
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
                                    style:
                                        const TextStyle(color: Colors.white)),
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
                  color: Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              //**FINAL DATE AND TIME/////////////////////////////////////////////////////////////////////////////////////////////////////////////
              const SizedBox(
                height: 25,
              ),
              Container(
                child: const Center(
                  child: Text(
                    'Pick your final Date and Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
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
                        setDateValuesAftePicked('finalDate');
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
                            color: const Color.fromRGBO(23, 32, 42, 1)
                                .withOpacity(1),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    endingDate == null
                                        ? 'Final Date'
                                        : DateFormat.yMd().format(endingDate),
                                    style:
                                        const TextStyle(color: Colors.white)),
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
                        setTimeValuesAftePicked('finalTime');
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
                            color: const Color.fromRGBO(23, 32, 42, 1)
                                .withOpacity(1),
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
                                    style:
                                        const TextStyle(color: Colors.white)),
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
                  color: Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),

              //**BOOKING BUTTON/////////////////////////////////////////////////////////////////////////////////////////////////////////////

              const SizedBox(
                height: 70,
              ),

              FlatButton(
                onPressed: () {
                  requestBookingSlot(pickedParkingSlotDetails);
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
                    color: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
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
