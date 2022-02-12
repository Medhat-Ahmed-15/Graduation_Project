// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:http/http.dart' as http;

class RequestParkingSlotDetailsProvider with ChangeNotifier {
  final String _authToken;
  final String _userId;

  RequestParkingSlotDetailsProvider(this._authToken, this._userId);

  //Add Request////////////////////////////////////////////////

  Future<void> postRequestParkingDetails(
      {String userId,
      String paymentMethod,
      String parkingAreaAddressName,
      String parkingSlotId,
      int totalCost,
      String startDateTime,
      String endDateTime,
      Map destinationLocMap}) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$_userId.json?auth=$_authToken';

    try {
      var response = await http.post(
        url,
        body: json.encode(
          {
            'userId': userId,
            'paymentMethod': paymentMethod,
            'parkingAreaAddressName': parkingAreaAddressName,
            'parkingSlotId': parkingSlotId,
            'totalCost': totalCost,
            'startDateTime': startDateTime,
            'endDateTime': endDateTime,
            'destinationLocMap': destinationLocMap
          },
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

//Delete Request////////////////////////////////////////////////

  Future<void> cancelRequest(BuildContext context) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$_userId.json?auth=$_authToken';

    await http.delete(url);
  }
}
