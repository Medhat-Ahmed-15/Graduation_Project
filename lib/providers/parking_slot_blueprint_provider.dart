import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParkingSlotBlueprintProvider with ChangeNotifier {
  String id;
  bool availability;
  String startDateTtime;
  String endDateTime;
  double latitude;
  double longitude;
  String userId;

  ParkingSlotBlueprintProvider(
      {this.id,
      this.availability,
      this.startDateTtime,
      this.latitude,
      this.longitude,
      this.endDateTime,
      this.userId});
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//This Function is called when the user presses on a specific slot
  Future<void> switchAvailability(String authToken, String startDateTime,
      String endDateTime, String userId) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$id.json?auth=$authToken';
    bool oldAvailability = availability;
    availability = !availability;

    var response = await http.patch(
      url,
      body: json.encode(
        {
          'availability': availability,
          'end_time': endDateTime,
          'id': id,
          'latitude': latitude,
          'longitude': longitude,
          'start_time': startDateTime,
          'userId': userId
        },
      ),
    );

    if (response.statusCode > 400) {
      availability = oldAvailability;
      notifyListeners();
      throw HttpException('error');
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

}
