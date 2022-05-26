import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:graduation_project/Notifications/notifications.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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

Future<void> switchParkingAvailability(String startDateTime, String endDateTime,
    String userId, String slotId) async {
  final String url =
      'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json?auth=$authToken';

  try {
    final getResponse = await http.get(Uri.parse(url));

    final extractedData = json.decode(getResponse.body) as Map<String, dynamic>;
    bool oldAvailability = extractedData['availability'];
    bool newAvailability = !oldAvailability;

    await http.patch(
      Uri.parse(url),
      body: json.encode(
        {
          'availability': newAvailability,
          'end_time': endDateTime,
          'id': slotId,
          'latitude': extractedData['latitude'],
          'longitude': extractedData['longitude'],
          'start_time': startDateTime,
          'userId': userId,
          'vip': extractedData['vip']
        },
      ),
    );
  } catch (error) {}
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

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
  final url = 'https://api.emailjs.com/api/v1.0/email/send';

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
    throw error;
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> sendCancellationEmail(
    String userName, String slotId, String toEmail) async {
  final url = 'https://api.emailjs.com/api/v1.0/email/send';

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
    throw error;
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
Future<void> setPickedParkingSlotIdAndAuthTokenInStorage(String id) async {
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

Future<Map<String, dynamic>> getPickedParkingSlotIdFromStorage() async {
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
        applePay: true,
        googlePay: true,
        testEnv: false,
        merchantCountryCode: 'EG',
        primaryButtonColor: Theme.of(context).primaryColor,
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

Future<void> getSensorDetectResultAtEndingTime() async {
  //since this function is called from alarm manager...so any variable I am gonna use must be from device storage
  try {
    var currentUserData = await getUserDataFromStorage();
    var pickedSlotIdAndAuthToken = await getPickedParkingSlotIdFromStorage();

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

    String urlForFetchinCurrentUser =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId.json?auth=$authToken';

    String urlForAccessingSpicificSlot =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId.json?auth=$authToken';

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

    if (extractedDataForAccessingSpicificSlot['sensorDetect'] == false) {
      //switching availability
      await http.patch(
        Uri.parse(urlForAccessingSpicificSlot),
        body: json.encode(
          {
            'availability': false,
            'end_time': 'empty',
            'id': pickedSlotId,
            'latitude': extractedDataForAccessingSpicificSlot['latitude'],
            'longitude': extractedDataForAccessingSpicificSlot['longitude'],
            'start_time': 'empty',
            'userId': currentUserId,
            'vip': extractedDataForAccessingSpicificSlot['vip']
          },
        ),
      );

      //Deleting request
      await http.delete(Uri.parse(urlforFetchingRecordedrequestId));

      await sendCancellationEmail(
          extractedDataForFetchinCurrentUser.values.first['name'],
          pickedSlotId,
          extractedDataForFetchinCurrentUser.values.first['email']);

      String urlForUpdatingFine =
          'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId/$userKey.json?auth=$authToken';

      await http.patch(Uri.parse(urlForUpdatingFine),
          body: json.encode({
            'penalty': 10,
          }));

      Notifications.createUserMissedHisSlotNotification();
    }
  } catch (error) {
    throw (error);
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

Future<void> getSensorDetectResultAfterEndingTime() async {
  //since this function is called from alarm manager...so any variable I am gonna use must be from device storage
  try {
    var currentUserData = await getUserDataFromStorage();
    var pickedSlotIdAndAuthToken = await getPickedParkingSlotIdFromStorage();

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

    String urlForFetchinCurrentUser =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId.json?auth=$authToken';

    String urlForAccessingSpicificSlot =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$pickedSlotId.json?auth=$authToken';

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
      //switching availability
      await http.patch(
        Uri.parse(urlForAccessingSpicificSlot),
        body: json.encode(
          {
            'availability': false,
            'end_time': 'empty',
            'id': pickedSlotId,
            'latitude': extractedDataForAccessingSpicificSlot['latitude'],
            'longitude': extractedDataForAccessingSpicificSlot['longitude'],
            'start_time': 'empty',
            'userId': currentUserId,
            'vip': extractedDataForAccessingSpicificSlot['vip']
          },
        ),
      );

      //Deleting request
      await http.delete(Uri.parse(urlforFetchingRecordedrequestId));

      await sendCancellationEmail(
          extractedDataForFetchinCurrentUser.values.first['name'],
          pickedSlotId,
          extractedDataForFetchinCurrentUser.values.first['email']);

      String urlForUpdatingFine =
          'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$currentUserId/$userKey.json?auth=$authToken';

      await http.patch(Uri.parse(urlForUpdatingFine),
          body: json.encode({
            'penalty': 10,
          }));

      Notifications.createUserMissedHisSlotNotification();
    }
  } catch (error) {
    throw (error);
  }
}
