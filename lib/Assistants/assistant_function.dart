import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    final response = await http.post(url,
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

Future<void> sendCancellationEmail(
    String userName, String slotId, String toEmail) async {
  final url = 'https://api.emailjs.com/api/v1.0/email/send';

  try {
    final response = await http.post(url,
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
