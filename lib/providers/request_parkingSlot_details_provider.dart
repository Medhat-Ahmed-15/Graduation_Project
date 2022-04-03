// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:http/http.dart' as http;

class RequestParkingSlotDetailsProvider with ChangeNotifier {
  final String _authToken;
  final String _userId;
  String _recordedrequestId;
  List<RequestedParkingSlotDetailsBluePrint> _recordedRequestsList = [];

  RequestParkingSlotDetailsProvider(this._authToken, this._userId);

  String get getRecorderRequestId {
    return _recordedrequestId;
  }

  List<RequestedParkingSlotDetailsBluePrint> get getRecordedIdsList {
    return [..._recordedRequestsList];
  }

  //Add Request////////////////////////////////////////////////

  Future<void> postRequestParkingDetails(
      {String userId,
      String paymentMethod,
      String parkingAreaAddressName,
      String parkingSlotId,
      int totalCost,
      String status,
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
            'destinationLocMap': destinationLocMap,
            'status': status
          },
        ),
      );

      final responseDecoded =
          json.decode(response.body) as Map<String, dynamic>;
      _recordedrequestId = responseDecoded['name'];
    } catch (error) {
      rethrow;
    }
  }

//Fetch Request////////////////////////////////////////////////

  Future<void> recordedRequests() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$_userId.json?auth=$_authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<RequestedParkingSlotDetailsBluePrint> recordedRequests = [];
      extractedData.forEach((key, slotData) {
        recordedRequests.add(
          RequestedParkingSlotDetailsBluePrint(
            userId: slotData['userId'],
            paymentMethod: slotData['paymentMethod'],
            endDateTime: slotData['endDateTime'],
            parkingAreaAddressName: slotData['id'],
            parkingSlotId: slotData['latitude'],
            totalCost: slotData['longitude'],
            status: slotData['status'],
            startDateTime: slotData['start_time'],
            destinationLocMap: slotData['destinationLocMap'],
          ),
        );
      });
      _recordedRequestsList = recordedRequests;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

//Update Request////////////////////////////////////////////////

  Future<void> updateRecordedRequest(String status) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$_userId/$_recordedrequestId.json?auth=$_authToken';

    try {
      await http.patch(
          url, //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'status': status}));

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

//Delete Request////////////////////////////////////////////////

  Future<void> cancelRequest(String requestId) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$_userId/$requestId.json?auth=$_authToken';

    await http.delete(url);
  }
}
