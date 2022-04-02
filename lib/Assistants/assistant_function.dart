import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendEmail(
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
          'service_id': 'service_3kzxsak',
          'template_id': 'template_8i0qn9a',
          'user_id': '495VrrNTCTf2ZiELs',
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
