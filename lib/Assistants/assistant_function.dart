import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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

Future<void> initPaymentSheet(context,
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

    final jsonResponse = jsonDecode(response.body);
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

    await Stripe.instance.presentPaymentSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment completed!')),
    );
  } catch (e) {
    if (e is StripeException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error from Stripe: ${e.error.localizedMessage}'),
        ),
      );
      print('Error from Stripe: ${e.error.localizedMessage}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error from Stripe: ${e.error.localizedMessage}');
    }
  }
}
