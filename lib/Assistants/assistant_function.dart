// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:graduation_project/widgets/recommendingAnotherSlotDialog.dart';
import 'package:graduation_project/widgets/sorryDialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<Map<String, Object>> getUserDataFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('userData')) {
    return null;
  }
  final extractedUserData =
      json.decode(prefs.getString('userData')) as Map<String, Object>;

  return extractedUserData;
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> updateUserNextBookFree(bool value) async {
  var response = await getUserDataFromStorage();

  String urlForUpdatingUserData =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Users/${currentUserOnline.id}/${response['userKey']}.json?auth=$authToken';

  try {
    await http.patch(Uri.parse(urlForUpdatingUserData),
        body: json.encode({
          'nextBookFree': value,
        }));
  } catch (error) {
    print('ERRORRR  updateUserNextBookFree::${error.toString()} ');
  }
}

Future<void> updateUserRating(String rate) async {
  var response = await getUserDataFromStorage();

  String urlForUpdatingUserData =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Users/${currentUserOnline.id}/${response['userKey']}.json?auth=$authToken';

  try {
    await http.patch(Uri.parse(urlForUpdatingUserData),
        body: json.encode({
          'rating': rate,
        }));
  } catch (error) {
    print('ERRORRR  updateUserRating::${error.toString()} ');
  }
}

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

DateTime convertStringToDateTime(String date) {
  DateTime dateTime = DateTime(
    int.parse(date.split(" ")[0].split("-")[0]),
    int.parse(date.split(" ")[0].split("-")[1]),
    int.parse(date.split(" ")[0].split("-")[2]),
    int.parse(date.split(" ")[1].split(":")[0]),
    int.parse(date.split(" ")[1].split(":")[1]),
  );

  return dateTime;
}

// ////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////

// Future<void> switchParkingAvailability(String slotId) async {
//   final String url =
//       'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json?auth=$authToken';

//   try {
//     final getResponse = await http.get(Uri.parse(url));

//     final extractedData = json.decode(getResponse.body) as Map<String, dynamic>;
//     bool oldAvailability = extractedData['availability'];
//     bool newAvailability = !oldAvailability;

//     await http.patch(
//       Uri.parse(url),
//       body: json.encode(
//         {
//           'availability': newAvailability,
//         },
//       ),
//     );
//   } catch (error) {
//     print('Switch Parking Availability Error 1: ${error}');
//     throw error;
//   }
// }

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<int> extendTime(String slotId, DateTime oldEndingDateTime) async {
  List<DateTimeRange> data = [];
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates.json?auth=$authToken';

  try {
    final getResponse = await http.get(Uri.parse(url));

    final allReservedTimes =
        json.decode(getResponse.body) as Map<String, dynamic>;

    if (allReservedTimes != null) {
      allReservedTimes.forEach((key, value) {
        Map<String, dynamic> nestedValue = value;

        nestedValue.forEach((key, value) {
          DateTime startDateTime =
              convertStringToDateTime(value['startingDateTime'].toString());

          DateTime endDateTime =
              convertStringToDateTime(value['endingDateTime'].toString());

          print(
              'Start Time: ${startDateTime.toString()} <*****************> End Time: ${endDateTime.toString()}');

          data.add(DateTimeRange(start: startDateTime, end: endDateTime));
        });
      });

      //Now I have filled the list, Next loop on it to check if there is available time to extend

      int minDiffTimeInMinutes = 1000000;
      int beforeOldEndingDateTimeCount = 0;

      for (int i = 0; i < data.length; i++) {
        if (data[i].start.isAfter(oldEndingDateTime) ||
            data[i].start.isAtSameMomentAs(oldEndingDateTime)) {
          print(
              ' ${data[i].start.toString()}    ISSS AFTERRRR     ${oldEndingDateTime.toString()}');
          int diffTimeInMinutes =
              data[i].start.difference(oldEndingDateTime).inMinutes;
          if (diffTimeInMinutes < minDiffTimeInMinutes) {
            minDiffTimeInMinutes = diffTimeInMinutes;
          }
        } else {
          beforeOldEndingDateTimeCount++;
        }
      }

      if (beforeOldEndingDateTimeCount == data.length) {
        return 1440;
      } else {
        return minDiffTimeInMinutes;
      }
    } else {
      return 1440; // this the total number of minutes in 24h because if there is no any reserved times after him he is free to extend how ever he wants
    }
  } catch (error) {
    print('Extend Time Error 1: ${error}');
    rethrow;
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> addNewReservationTime(String startDateTime, String endDateTime,
    String userId, String slotId) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId.json?auth=$authToken';

  try {
    Map<String, dynamic> newReservationDate = {
      'startingDateTime': startDateTime,
      'endingDateTime': endDateTime
    };

    var response = await http.post(
      Uri.parse(url),
      body: json.encode(
        newReservationDate,
      ),
    );

    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    reservedDateTimeResponseKey = extractedData['name'];

    print('TEST::  $reservedDateTimeResponseKey');
  } catch (error) {}
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> updateEndingTimeReservedDate(
    String endDateTime, String userId, String slotId) async {
  final String url1 =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId.json?auth=$authToken';

  try {
    var getResponse = await http.get(Uri.parse(url1));

    var getResponseDecoded =
        json.decode(getResponse.body) as Map<String, dynamic>;

    print('First Keyyy:: ${getResponseDecoded.keys.first}');

    final String url2 =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId/${getResponseDecoded.keys.first}.json?auth=$authToken';

    await http.patch(
      Uri.parse(url2),
      body: json.encode({
        'endingDateTime': endDateTime,
      }),
    );
  } catch (error) {}
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<String> getEndingTimeReservedDate(String userId, String slotId) async {
  final String url1 =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId.json?auth=$authToken';

  try {
    var getResponse1 = await http.get(Uri.parse(url1));

    var getResponseDecoded1 =
        json.decode(getResponse1.body) as Map<String, dynamic>;

    final String url2 =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId/${getResponseDecoded1.keys.first}.json?auth=$authToken';

    var getResponse2 = await http.get(Uri.parse(url2));

    var getResponseDecoded2 =
        json.decode(getResponse2.body) as Map<String, dynamic>;

    return getResponseDecoded2['endingDateTime'];
  } catch (error) {}
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> removeReservedTimeFromParkingSlot(
    String userId, String slotId) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId/reservationDates/$userId.json?auth=$authToken';

  try {
    await http.delete(Uri.parse(url));
  } catch (error) {}
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> switchGate(String slotId, int value) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json?auth=$authToken';

  try {
    await http.patch(
      Uri.parse(url),
      body: json.encode(
        {
          'gateOpen': value,
        },
      ),
    );
  } catch (error) {
    print('Open Gate Error:  ${error}');
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> chargeUsersPenaltyToZero() async {
  var currentUserData = await getUserDataFromStorage();
  if (currentUserData['userId'] == null ||
      DateTime.parse(currentUserData['expiryDate']).isBefore(DateTime.now())) {
    return;
  }
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId/${currentUserData['userKey']}.json?auth=$authToken';

  try {
    await http.patch(Uri.parse(url),
        body: json.encode({
          'penalty': 0,
        }));
  } catch (error) {
    print('Charge User Penalty:  ${error}');
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<void> changeUsersCrossedLimit(bool value) async {
  var currentUserData = await getUserDataFromStorage();
  if (currentUserData['userId'] == null ||
      DateTime.parse(currentUserData['expiryDate']).isBefore(DateTime.now())) {
    return;
  }
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Users/${currentUserOnline.id}/${currentUserData['userKey']}.json?auth=$authToken';

  try {
    await http.patch(Uri.parse(url),
        body: json.encode({
          'crossedLimit': value,
        }));
  } catch (error) {
    print('Change Users Crossed Limit:  ${error}');
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<bool> checkParkedCorrectly(String slotId) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json?auth=$authToken';

  try {
    final getResponse = await http.get(Uri.parse(url));

    final extractedData = json.decode(getResponse.body) as Map<String, dynamic>;

    if (extractedData['parkedcorrectly'] == true) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    print('Open Gate Error:  ${error}');
  }
}

Future<void> sendConfirmationEmail(
    {String startingDate,
    String endingDate,
    String userName,
    String slotId,
    String toEmail,
    String areaName,
    int randomId1,
    int randomId2,
    int randomId3,
    int randomId4}) async {
  const url = 'https://api.emailjs.com/api/v1.0/email/send';

  try {
    final response = await http.post(Uri.parse(url),
        headers: {
          'origin': 'http://localhost:3000',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': 'service_7xe9wbf',
          'template_id': 'template_59ix09i',
          'user_id': '7m7B7E8CzRI4qRDgi',
          'template_params': {
            'to_email': toEmail,
            'to_name': userName,
            'slot_id': slotId,
            'start_date': startingDate,
            'end_date': endingDate,
            'area_name': areaName,
            'random_Id1': randomId1,
            'random_Id2': randomId2,
            'random_Id3': randomId3,
            'random_Id4': randomId4
          }
        }));
  } catch (error) {
    rethrow;
  }
}

Future<void> sendConfirmationSMS(
    int randomId1, int randomId2, int randomId3, int randomId4) async {
  try {
    var twilioFlutter = TwilioFlutter(
        accountSid: 'AC4d54089cf5292d17b75ceb3842f000ba',
        authToken: '7b6992cf17f4f06bd1a103a5152156c7',
        twilioNumber: '+17075040983');

    // await twilioFlutter.sendSMS(
    //     toNumber: '+201282914670',
    //     messageBody:
    //         'Your Verification code is: ${randomId1}:${randomId2}:${randomId3}:${randomId4}}');
  } on SocketException {
    Fluttertoast.showToast(
        msg: 'An error occurred,Please check you internet connection',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.grey[500],
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> sendCancellationEmail(
    String userName, String slotId, String toEmail) async {
  const url = 'https://api.emailjs.com/api/v1.0/email/send';

  try {
    final response = await http.post(Uri.parse(url),
        headers: {
          'origin': 'http://localhost:3000',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': 'service_7xe9wbf',
          'template_id': 'template_mg3h3hp',
          'user_id': '7m7B7E8CzRI4qRDgi',
          'template_params': {
            'to_email': toEmail,
            'to_name': userName,
            'slot_id': slotId,
          }
        }));
  } catch (error) {
    rethrow;
  }
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Future<void> setVerificationCodeInStorage(
    int randomId1, int randomId2, int randomId3, int randomId4) async {
  final prefs = await SharedPreferences.getInstance();

  final verificationCode = json.encode({
    'randomId1': randomId1,
    'randomId2': randomId2,
    'randomId3': randomId3,
    'randomId4': randomId4,
  });

  prefs
      .setString('verificationCode', verificationCode)
      .then((value) => print(value));
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Future<void> setPickedParkingSlotIdAndRecordedRequestDetailsIdInStorage(
    String id) async {
  final prefs = await SharedPreferences.getInstance();

  final pickedParkingSlotIdAndAuthToken = json.encode({
    'pickedParkingSlotId': id,
    'singleRecordedRequestDetailsId': singleRecordedRequestDetailsId,
  });

  prefs
      .setString(
          'pickedParkingSlotIdAndAuthToken', pickedParkingSlotIdAndAuthToken)
      .then((value) => print(
          'Response from setPickedParkingSlotIdAndAuthTokenInStorage: $value'));
}

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Future<Map<String, dynamic>>
    getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('pickedParkingSlotIdAndAuthToken')) {
      return null;
    }
    final extractedVerificationCode =
        json.decode(prefs.getString('pickedParkingSlotIdAndAuthToken'))
            as Map<String, dynamic>;

    return extractedVerificationCode;
  } catch (error) {
    print('catchError  $error');
  }
}

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Future<String> getVerificationCodeFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('verificationCode')) {
      return null;
    }
    final extractedVerificationCode = json
        .decode(prefs.getString('verificationCode')) as Map<String, dynamic>;

    String randomId1 = extractedVerificationCode['randomId1'].toString();
    String randomId2 = extractedVerificationCode['randomId2'].toString();
    String randomId3 = extractedVerificationCode['randomId3'].toString();
    String randomId4 = extractedVerificationCode['randomId4'].toString();

    return randomId1 + randomId2 + randomId3 + randomId4;
  } catch (error) {
    print('catchError  $error');
  }
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

Future<bool> initPaymentSheet(context,
    {@required String email, @required int amount}) async {
  try {
    // 1. create payment intent on the server
    final response = await http.post(
        Uri.parse(
            'https://us-central1-rakane-13d27.cloudfunctions.net/stripePaymentIntentRequest'),
        body: {
          'email': email,
          'amount': amount.toString(),
        });

    var jsonResponse = jsonDecode(response.body);
    log(jsonResponse.toString());

    //2. initialize the payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['paymentIntent'],
        merchantDisplayName: 'Flutter Stripe Store Demo',
        customerId: jsonResponse['customer'],
        customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
        style: ThemeMode.dark,
      ),
    );

    await Stripe.instance.presentPaymentSheet(
      parameters: PresentPaymentSheetParameters(
          clientSecret: jsonResponse['paymentIntent'], confirmPayment: true),
    );

    jsonResponse = null;

    return true;
  } catch (e) {
    if (e is StripeException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error from Stripe: ${e.error.localizedMessage}'),
        ),
      );
      print('Error from Stripe: ${e.error.localizedMessage}');
      return false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error from Stripe: ${e.error.localizedMessage}');
      return false;
    }
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> createNotification(String body) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(
          100000), //If you want to be able to display multiple instances of a specific notification, then you must provide a unique id.
      channelKey: 'goPark',
      title: 'Hey there,',
      body: body,
      bigPicture: 'asset://assets/images/alert.png',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//since i call this function in alarm manager it can not take parameters so thats why I created another notification functin to write in it static body
Future<void> createReminderForReservedSlotNotification() async {
  await AwesomeNotifications()
      .createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(
          100000), //If you want to be able to display multiple instances of a specific notification, then you must provide a unique id.
      channelKey: 'goPark',
      title: 'Hey there,',
      body:
          'This is a reminder that your reserved parking slot will be available after 15 min',
      bigPicture: 'asset://assets/images/alert.png',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  )
      .catchError((error) {
    print(
        'NOTIFICATION createReminderForReservedSlotNotification ERROR::: ${error.toString()}');
  });
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> getSensorDetectResultAtEndingTime() async {
  //since this function is called from alarm manager...so any variable I am gonna use must be from device storage
  try {
    var currentUserData = await getUserDataFromStorage();
    var pickedSlotIdAndAuthToken =
        await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();

    if (currentUserData['userId'] == null ||
        DateTime.parse(currentUserData['expiryDate'])
            .isBefore(DateTime.now())) {
      return;
    }

    String pickedSlotId =
        pickedSlotIdAndAuthToken['pickedParkingSlotId'].toString();
    String authToken = currentUserData['token'];
    String userKey = currentUserData['userKey'];
    String recordedRequestId =
        pickedSlotIdAndAuthToken['singleRecordedRequestDetailsId'].toString();
    String currentUserId = currentUserData['userId'];
    int currentUserWrongUseCount = currentUserData['wrongUse'];
    int currentUserWrongUseCountPlusOne = currentUserWrongUseCount + 1;

    print('currentUserWrongUseCount:: ${currentUserWrongUseCount}');
    print(
        'currentUserWrongUseCountPlusOne:: ${currentUserWrongUseCountPlusOne}');

    String urlForFetchinCurrentUser =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId.json?auth=$authToken';

    String urlForAccessingSpicificSlot =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId.json?auth=$authToken';

    String urlForFetchingAccessingSingleReservedTime =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId/reservationDates/$currentUserId.json?auth=$authToken';

    String urlforFetchingRecordedrequestId =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    String urlForUpdatingUserData =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId/$userKey.json?auth=$authToken';

    //*******************************************************************************
    //*******************************************************************************

    var responseForFetchinCurrentUser =
        await http.get(Uri.parse(urlForFetchinCurrentUser));

    var extractedDataForFetchinCurrentUser =
        json.decode(responseForFetchinCurrentUser.body) as Map<String, dynamic>;

    if (extractedDataForFetchinCurrentUser == null) {
      return;
    }

    //*******************************************************************************
    //*******************************************************************************

    final responseForAccessingSpicificSlot =
        await http.get(Uri.parse(urlForAccessingSpicificSlot));

    final extractedDataForAccessingSpicificSlot = json
        .decode(responseForAccessingSpicificSlot.body) as Map<String, dynamic>;

    if (extractedDataForAccessingSpicificSlot['sensorDetect'] == false) {
      //Deleting Reserved Time
      await http.delete(Uri.parse(urlForFetchingAccessingSingleReservedTime));

      //Deleting request
      await http.delete(Uri.parse(urlforFetchingRecordedrequestId));

      await sendCancellationEmail(
          extractedDataForFetchinCurrentUser.values.first['name'],
          pickedSlotId,
          extractedDataForFetchinCurrentUser.values.first['email']);

      await http.patch(Uri.parse(urlForUpdatingUserData),
          body: json.encode({
            'penalty': 10,
            'wrongUse': currentUserWrongUseCountPlusOne,
          }));

      createNotification(
          'Looks like you missed your parking slot, you will be charged 10 extra fees');
    }
  } catch (error) {
    rethrow;
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> getSensorDetectResultAfterEndingTime() async {
  //since this function is called from alarm manager...so any variable I am gonna use must be from device storage
  try {
    var currentUserData = await getUserDataFromStorage();
    var pickedSlotIdAndAuthToken =
        await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();

    if (currentUserData['userId'] == null ||
        DateTime.parse(currentUserData['expiryDate'])
            .isBefore(DateTime.now())) {
      return;
    }

    String pickedSlotId =
        pickedSlotIdAndAuthToken['pickedParkingSlotId'].toString();
    String authToken = currentUserData['token'];
    String userKey = currentUserData['userKey'];
    String recordedRequestId =
        pickedSlotIdAndAuthToken['singleRecordedRequestDetailsId'].toString();
    String currentUserId = currentUserData['userId'];
    int currentUserWrongUseCount = currentUserData['wrongUse'];
    int currentUserWrongUseCountPlusOne = currentUserWrongUseCount + 1;

    String urlForFetchinCurrentUser =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId.json?auth=$authToken';

    String urlForAccessingSpicificSlot =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId.json?auth=$authToken';

    String urlForUpdatingUserData =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId/$userKey.json?auth=$authToken';

    String urlForFetchingAccessingSingleReservedTime =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId/reservationDates/$currentUserId.json?auth=$authToken';

    String urlforFetchingRecordedrequestId =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    //*******************************************************************************
    //*******************************************************************************

    var responseForFetchinCurrentUser =
        await http.get(Uri.parse(urlForFetchinCurrentUser));

    var extractedDataForFetchinCurrentUser =
        json.decode(responseForFetchinCurrentUser.body) as Map<String, dynamic>;

    if (extractedDataForFetchinCurrentUser == null) {
      return;
    }

    //*******************************************************************************
    //*******************************************************************************

    final responseForAccessingSpicificSlot =
        await http.get(Uri.parse(urlForAccessingSpicificSlot));

    final extractedDataForAccessingSpicificSlot = json
        .decode(responseForAccessingSpicificSlot.body) as Map<String, dynamic>;

    if (extractedDataForAccessingSpicificSlot['sensorDetect'] == true) {
//Deleting Reserved Time
      await http.delete(Uri.parse(urlForFetchingAccessingSingleReservedTime));

      //Deleting request
      await http.delete(Uri.parse(urlforFetchingRecordedrequestId));

      //Update 'crossedLimit' to true

      await http.patch(Uri.parse(urlForUpdatingUserData),
          body: json.encode({
            'crossedLimit': true,
            'wrongUse': currentUserWrongUseCountPlusOne,
          }));

      createNotification(
          'You crossed your reserved time, you will be charged 25EG per hour when you leave or next time');
    }
  } catch (error) {
    rethrow;
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<bool> checkParkingSlotSensorDetect(String slotId) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json';

  try {
    final getResponse = await http.get(Uri.parse(url));

    final extractedData = json.decode(getResponse.body) as Map<String, dynamic>;

    return extractedData['sensorDetect'];
  } catch (error) {
    print('Error checkParkingSlotAvailability:  ${error}');
  }
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

Future<Map<String, bool>> machineLearningProcess(String position) async {
  //url to send the post request to

  try {
    const url =
        'https://modeltest-be734-default-rtdb.firebaseio.com/slots/1.json';

    //sending a post request to the url
    await http.patch(
      Uri.parse(url),
      body: json.encode({'x': position}),
    );

    var getResponse = await http.get(Uri.parse(url));

    var getResponseDecoded =
        json.decode(getResponse.body) as Map<String, dynamic>;

    print('Recommended Slot:: ${getResponseDecoded['recommended_slot']}');

    if (double.parse(getResponseDecoded['recommended_slot']) > 1 &&
        double.parse(getResponseDecoded['recommended_slot']) < 70) {
      recommendedId = 'a10';
    } else {
      recommendedId = 'a5';
    }

    var slotSensorDetect = await checkParkingSlotSensorDetect(recommendedId);

    return {recommendedId: slotSensorDetect};
  } on SocketException {
    throw const SocketException('Internet Connection');
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

Future<void> getSensorDetectResultAtStartingTime() async {
  //since this function is called from alarm manager...so any variable I am gonna use must be from device storage
  try {
    var pickedSlotIdAndAuthToken =
        await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();

    String pickedSlotId =
        pickedSlotIdAndAuthToken['pickedParkingSlotId'].toString();

    String urlForAccessingSpicificSlot =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId.json';

    final responseForAccessingSpicificSlot =
        await http.get(Uri.parse(urlForAccessingSpicificSlot));

    final extractedDataForAccessingSpicificSlot = json
        .decode(responseForAccessingSpicificSlot.body) as Map<String, dynamic>;

    if (extractedDataForAccessingSpicificSlot['sensorDetect'] == true) {
      String pickedParkingSlotLocationLocation =
          '${extractedDataForAccessingSpicificSlot['longitude']},${extractedDataForAccessingSpicificSlot['latitude']}';
      var response =
          await machineLearningProcess(pickedParkingSlotLocationLocation);

      print('11111111111:: ${response.keys.first}');
      print('11111111111:: ${response.values.first}');

      final prefs = await SharedPreferences.getInstance();

      final recommendAnotherSlot = json.encode({
        'recommendAnotherSlot': true,
        'recommendedSlot': response.keys.first,
        'recommendedSLotSensorDetect': response.values.first,
      });

      prefs
          .setString('recommendAnotherSlot', recommendAnotherSlot)
          .then((value) => print('Response from recommendAnotherSlot: $value'));

      createNotification(
          'Hey there, Please note that your reserved parking slot is still not empty');
    } else {
      createNotification('Hey there, Your parking slot is now available');
    }
  } catch (error) {
    rethrow;
  }
}

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Future<void> getRecommendAnotherSlotFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('recommendAnotherSlot')) {
      return;
    }
    final extractedRecommendAnotherSlotResult =
        json.decode(prefs.getString('recommendAnotherSlot'))
            as Map<String, dynamic>;
    print('///////////////////////////////////////');
    print(extractedRecommendAnotherSlotResult['recommendAnotherSlot']);
    print(extractedRecommendAnotherSlotResult['recommendedSlot']);
    print(extractedRecommendAnotherSlotResult['recommendedSLotSensorDetect']);

    if (extractedRecommendAnotherSlotResult['recommendAnotherSlot'] == true &&
        currentUserOnline.crossedLimit == false) {
      if (extractedRecommendAnotherSlotResult['recommendedSLotSensorDetect'] ==
          false) {
        recommendedId = extractedRecommendAnotherSlotResult['recommendedSlot'];
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('recommendAnotherSlot');
        showDialog(
          context: mapScreenContext,
          barrierColor: Colors.white24,
          builder: (BuildContext context) => RecommendingAnotherSlotDialog(
            'Unfortunately your reserved parking slot is still not empty due to unexpected behavior from the user whose reservation is before you, we recommend for you parking slot:"${extractedRecommendAnotherSlotResult['recommendedSlot']}" as an alternative. Note that if you confirmed your old reservation will be deleted ',
          ),
        );
      } else {
        recommendedId = '';
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('recommendAnotherSlot');
        showDialog(
            context: mapScreenContext,
            barrierColor: Colors.white24,
            builder: (BuildContext context) => SorryDialog(
                'We tried to recommend for you another parking slot but unfortunately there is\'nt any availabile, Our appology for what happened, your next reservation will be for free 😊'));

        await updateUserNextBookFree(true);

        var response =
            await getPickedParkingSlotIdAndRecordedRequestDetailsIdFromStorage();
        String recordedRequestId =
            response['singleRecordedRequestDetailsId'].toString();
        String pickedSlotId = response['pickedParkingSlotId'].toString();

        //Remove Reserved Time From ParkingSlot
        await removeReservedTimeFromParkingSlot(currentUserId, pickedSlotId);

        //Deleting request
        await RequestParkingSlotDetailsProvider.deleteRecordedRequestDetatils(
            recordedRequestId);
      }
    }
  } catch (error) {
    print('catchError  $error');
  }
}
