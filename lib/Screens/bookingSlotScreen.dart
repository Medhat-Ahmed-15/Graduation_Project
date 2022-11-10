// ignore_for_file: file_names
import 'dart:async';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dialogs/dialogs/choice_dialog.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/makeMyNextReservationForFreeDialog.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/widgets/reservedTimeSlotsDialog.dart';
import 'package:graduation_project/widgets/sorryDialog.dart';
import 'package:graduation_project/widgets/successfullyBookedDialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class BookingSlotScreen extends StatefulWidget {
  static const routeName = '/BookingSlotScreen';

  @override
  State<BookingSlotScreen> createState() => _BookingSlotScreenState();
}

class _BookingSlotScreenState extends State<BookingSlotScreen> {
  bool loading = false;
  TimeOfDay startingTime;
  TimeOfDay endingTime;
  DateTime endingDate;
  DateTime endDateTime;
  DateTime startDateTime;
  DateTime startingDate;
  bool checkUserPrevReseervationsLoading = false;

  int totalCost;

  //Timer cancelRequestTimer;

  Random random = Random();

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  List<DateTimeRange> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (recommendedId != '') {
      setState(() {
        startingTime =
            TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

        startingDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
      });
    }

    if (pickedParkingSlot.reservationDates != null) {
      pickedParkingSlot.reservationDates.forEach(
        (key, value) {
          Map<String, dynamic> nestedValue = value;

          nestedValue.forEach(
            (key, value) {
              print(
                  'Start Time: ${value['startingDateTime']} <*****************> End Time: ${value['endingDateTime']}');

              DateTime startDateTime =
                  convertStringToDateTime(value['startingDateTime'].toString());

              DateTime endDateTime =
                  convertStringToDateTime(value['endingDateTime'].toString());

              data.add(DateTimeRange(start: startDateTime, end: endDateTime));
            },
          );
        },
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, 31),
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

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  bool checkIfDateTimeAvailable() {
    if (pickedParkingSlot.reservationDates != null) {
      int counter = 0;
      DateTime startDateTime = DateTime(startingDate.year, startingDate.month,
          startingDate.day, startingTime.hour, startingTime.minute);
      DateTime endDateTime = DateTime(endingDate.year, endingDate.month,
          endingDate.day, endingTime.hour, endingTime.minute);
      for (int i = 0; i < data.length; i++) {
        if ((startDateTime.isAfter(data[i].start) &&
                endDateTime.isBefore(data[i].end)) ||
            ((startDateTime.isAtSameMomentAs(data[i].start) &&
                endDateTime.isAfter(data[i].end))) ||
            (startDateTime.isBefore(data[i].start) &&
                endDateTime.isAfter(data[i].end)) ||
            (startDateTime.isBefore(data[i].start) &&
                endDateTime.isAtSameMomentAs(data[i].end)) ||
            (startDateTime.isAfter(data[i].start) &&
                startDateTime.isBefore(data[i].end) &&
                endDateTime.isAfter(data[i].end)) ||
            (startDateTime.isBefore(data[i].start) &&
                endDateTime.isAfter(data[i].start) &&
                endDateTime.isBefore(data[i].end))) {
          counter++;
        }
      }

      if (counter == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  bool checkEndDateTimeIsAfterStartDateTime() {
    DateTime startDateTime = DateTime(startingDate.year, startingDate.month,
        startingDate.day, startingTime.hour, startingTime.minute);
    DateTime endDateTime = DateTime(endingDate.year, endingDate.month,
        endingDate.day, endingTime.hour, endingTime.minute);
    if (endDateTime.isBefore(startDateTime)) {
      return false;
    } else {
      return true;
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> updatePickedParkingSlotAndSendEmailAndSMS() async {
    String initialtDateTime = startDateTime.toString();
    String finalDateTime = endDateTime.toString();

    String addressName = pickedparkingSlotAreaLocation.placeName;

    Address destinationAddress = Address(
        placeName: addressName,
        latitude: pickedParkingSlot.latitude,
        longitude: pickedParkingSlot.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Booking your slot, PLease wait...',
            ));

    pickedParkingSlotLocation = destinationAddress;

    await addNewReservationTime(initialtDateTime, finalDateTime,
        currentUserOnline.id, pickedParkingSlot.id);

    int randomId1 = random.nextInt(10);
    int randomId2 = random.nextInt(10);
    int randomId3 = random.nextInt(10);
    int randomId4 = random.nextInt(10);

    await setVerificationCodeInStorage(
        randomId1, randomId2, randomId3, randomId4);

    await sendConfirmationEmail(
        startingDate: initialtDateTime,
        endingDate: finalDateTime,
        userName: currentUserOnline.name,
        slotId: pickedParkingSlot.id,
        toEmail: currentUserOnline.email,
        randomId1: randomId1,
        randomId2: randomId2,
        randomId3: randomId3,
        randomId4: randomId4,
        areaName: pickedparkingSlotAreaLocation.placeName);

    await sendConfirmationSMS(randomId1, randomId2, randomId3, randomId4);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessfullyBookedDialog(),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

    totalCost = (timeInMinutesBetween * (1 / 6)).round();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> saveParkingRequestDetails() async {
    String userId = Provider.of<AuthProvider>(context, listen: false).getUserID;
    String parkingAreaAddressName = pickedparkingSlotAreaLocation.placeName;
    String parkingSlotId = pickedParkingSlot.id;
    int cost = totalCost;
    String initialtDateTime = startDateTime.toString();
    String finalDateTime = endDateTime.toString();

    Map destinationLocMap = {
      'latitude': pickedParkingSlot.latitude.toString(),
      'longitude': pickedParkingSlot.longitude.toString(),
    };

    await RequestParkingSlotDetailsProvider.postRequestParkingDetails(
        userId: userId,
        parkingAreaAddressName: parkingAreaAddressName,
        destinationLocMap: destinationLocMap,
        endDateTime: finalDateTime,
        parkingSlotId: parkingSlotId,
        paymentMethod: 'online',
        status: 'pending',
        startDateTime: initialtDateTime,
        vip: pickedParkingSlot.vip,
        totalCost: cost);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Book your slot'),
    );

    return Scaffold(
        backgroundColor: colorProviderObj.generalCardColor,
        drawer: MainDrawer(),
        appBar: appBar,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height.round() <= 781
                        ? 240
                        : 250.0,
                    decoration: BoxDecoration(
                      color: colorProviderObj.genralBackgroundColor,
                    ),
                    child: Column(children: [
                      Container(
                        margin: const EdgeInsets.all(20),
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
                        margin: const EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            pickedparkingSlotAreaLocation.placeName,
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: colorProviderObj.textColor),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        'Slot Id: ' + pickedParkingSlot.id,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                      Expanded(child: Container()),
                      FlatButton(
                        onPressed: () {
                          showDialog(
                              barrierColor: Colors.white24,
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) =>
                                  ReservedTimeSlotsDialog());
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                spreadRadius: 2,
                                offset: Offset(0.2, 0.2),
                              ),
                            ],
                            color: colorProviderObj.genralBackgroundColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Show Reserved Times',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorProviderObj.textColor),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                    ]),
                  ),
                ),
                // Divider(
                //   color: colorProviderObj.generalCardColor,
                // ),

                Expanded(child: Container()),

                if (pickedParkingSlot.id == 'a10')
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorProviderObj.genralBackgroundColor,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Image.asset(
                          'assets/images/street1.jpg',
                          fit: BoxFit.fill,
                        )),
                  ),

                if (pickedParkingSlot.id == 'a5')
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorProviderObj.genralBackgroundColor,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              spreadRadius: 2,
                              offset: Offset(0.2, 0.2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Image.asset(
                          'assets/images/street2.jpg',
                          fit: BoxFit.fill,
                        )),
                  ),
                if (pickedParkingSlot.id == 'a10' ||
                    pickedParkingSlot.id == 'a5')
                  Expanded(child: Container()),
                Center(
                  child: Text(
                    'Pick Your Initial Date And Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorProviderObj.textColor),
                  ),
                ),
                Expanded(child: Container()),

                //**INITIAL DATE AND TIME/////////////////////////////////////////////////////////////////////////////////////////////////////////////

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Container()),

                    Image.asset(
                      'assets/images/calendar.png',
                      height: 35.0,
                      width: 35.0,
                    ),

                    //initial Date****************
                    FlatButton(
                      onPressed: recommendedId == ''
                          ? () {
                              setDateValuesAftePicked('initialDate', context);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          width: 110,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorProviderObj.genralBackgroundColor,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                spreadRadius: 2,
                                offset: Offset(0.2, 0.2),
                              ),
                            ],
                            color: colorProviderObj.generalCardColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
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
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/clock.png',
                      height: 35.0,
                      width: 35.0,
                    ),
                    //initial Time****************
                    FlatButton(
                      onPressed: recommendedId == ''
                          ? () {
                              setTimeValuesAftePicked('initialTime', context);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          width: 110,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorProviderObj.genralBackgroundColor,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2.0,
                                spreadRadius: 2,
                                offset: Offset(0.2, 0.2),
                              ),
                            ],
                            color: colorProviderObj.generalCardColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
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
                  ],
                ),

                Expanded(child: Container()),

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
                Expanded(child: Container()),

                Center(
                  child: Text(
                    'Pick Your Final Date And Time',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorProviderObj.textColor),
                  ),
                ),
                Expanded(child: Container()),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Container()),

                    Image.asset(
                      'assets/images/calendar.png',
                      height: 35.0,
                      width: 35.0,
                    ),

                    //Final Date****************
                    FlatButton(
                      onPressed: () {
                        setDateValuesAftePicked('finalDate', context);
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            width: 110,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorProviderObj.genralBackgroundColor,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 2.0,
                                  spreadRadius: 2,
                                  offset: Offset(0.2, 0.2),
                                ),
                              ],
                              color: colorProviderObj.generalCardColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
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

                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/clock.png',
                      height: 35.0,
                      width: 35.0,
                    ),
                    //FInal Time****************
                    FlatButton(
                      onPressed: () {
                        setTimeValuesAftePicked('finalTime', context);
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            width: 110,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorProviderObj.genralBackgroundColor,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 2.0,
                                  spreadRadius: 2,
                                  offset: Offset(0.2, 0.2),
                                ),
                              ],
                              color: colorProviderObj.generalCardColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
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
                  ],
                ),

                Expanded(child: Container()),

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

                //**BOOKING BUTTON /////////////////////////////////////////////////////////////////////////////////////////////////////////////

                Expanded(child: Container()),

                FlatButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        checkUserPrevReseervationsLoading = true;
                      });
                      var response = await RequestParkingSlotDetailsProvider
                          .checkUserStatusBeforeBooking();

                      setState(() {
                        checkUserPrevReseervationsLoading = false;
                      });

                      if (response == false) {
                        showDialog(
                            context: context,
                            barrierColor: Colors.white24,
                            builder: (BuildContext context) => SorryDialog(
                                'Sorry,you can\'t book a new slot while you still didn\'t leave from your previous reserved slot'));
                        return;
                      }

                      if (!checkIfDateTimeAvailable()) {
                        if (recommendedId == '') {
                          showDialog(
                              context: context,
                              barrierColor: Colors.white24,
                              builder: (BuildContext context) => SorryDialog(
                                  'Sorry,this parking slot is occupied at this time'));
                        } else if (recommendedId != '') {
                          showDialog(
                              context: mapScreenContext,
                              barrierColor: Colors.white24,
                              builder: (BuildContext context) =>
                                  MakeMyNextReservationForFreeDialog(
                                      'Unfortunately the parking slot is occupied At This Time, our appology for what happened😥'));
                        }

                        return;
                      }

                      if (!checkEndDateTimeIsAfterStartDateTime()) {
                        showDialog(
                            context: context,
                            barrierColor: Colors.white24,
                            builder: (BuildContext context) => SorryDialog(
                                'Sorry,your ending date and time must be after your starting date and time'));
                        return;
                      }

                      calculateCost();

                      final choice = ChoiceDialog(
                        dialogBackgroundColor:
                            colorProviderObj.generalCardColor,
                        title: 'Estimated Cost: $totalCost EG',
                        titleColor: Theme.of(context).primaryColor,
                        message:
                            'Starting Date \n ${startingDate.year}/${startingDate.month}/${startingDate.day} - ${startingTime.hour}:${startingTime.minute}\n\n Ending Date \n ${endingDate.year}/${endingDate.month}/${endingDate.day} - ${endingTime.hour}:${endingTime.minute}',
                        messageColor: colorProviderObj.textColor,
                        buttonOkText: 'Confirm',
                        buttonOkOnPressed: () async {
                          await updatePickedParkingSlotAndSendEmailAndSMS();
                          await saveParkingRequestDetails();
                          await setPickedParkingSlotIdAndRecordedRequestDetailsIdInStorage(
                              pickedParkingSlot.id);

                          await AndroidAlarmManager.oneShotAt(
                              DateTime(
                                  endingDate.year,
                                  endingDate.month,
                                  endingDate.day,
                                  endingTime.hour,
                                  endingTime.minute),
                              1,

                              //3ashan 2ashoof lw magasg asln el slot
                              getSensorDetectResultAtEndingTime);

                          await AndroidAlarmManager.oneShotAt(
                              DateTime(
                                  endingDate.year,
                                  endingDate.month,
                                  endingDate.day,
                                  endingTime.hour,
                                  endingTime.minute + 2),
                              2,
                              getSensorDetectResultAfterEndingTime);

                          // await AndroidAlarmManager.oneShotAt(
                          //     DateTime(
                          //         startingDate.year,
                          //         startingDate.month,
                          //         startingDate.day,
                          //         startingTime.hour,
                          //         startingTime
                          //             .minute) /* .subtract(const Duration(minutes: 15))*/,
                          //     3,
                          //     createReminderForReservedSlotNotification);

                          await AndroidAlarmManager.oneShotAt(
                              DateTime(
                                  startingDate.year,
                                  startingDate.month,
                                  startingDate.day,
                                  startingTime.hour,
                                  startingTime.minute),
                              4,
                              getSensorDetectResultAtStartingTime);
                        },
                      );
                      choice.show(context, barrierColor: Colors.white);
                    } catch (error) {
                      print(
                          'Check User Status Before Booking Error2 :: $error');
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 300,
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
                    child: Align(
                      alignment: Alignment.center,
                      child: checkUserPrevReseervationsLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'GoPark',
                              style: TextStyle(
                                  fontFamily: 'Yellowtail',
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ));
  }
}
