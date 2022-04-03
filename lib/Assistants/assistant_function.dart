import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendConfirmationEmail(
    {String startingDate,
    String endingDate,
    String userName,
    String slotId,
    String toEmail,
    String areaName}) async {
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
