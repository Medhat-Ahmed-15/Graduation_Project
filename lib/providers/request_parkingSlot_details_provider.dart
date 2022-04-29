// ignore_for_file: file_names

import 'dart:convert';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/requested_parkingSlot_details_bluePrint.dart';
import 'package:http/http.dart' as http;

class RequestParkingSlotDetailsProvider {
  static List<RequestedParkingSlotDetailsBluePrint> _scheduledRequestsList = [];
  static List<RequestedParkingSlotDetailsBluePrint> _historyRequestsList = [];

  static List<RequestedParkingSlotDetailsBluePrint>
      get getScheduledRequestsList {
    return [..._scheduledRequestsList];
  }

  static List<RequestedParkingSlotDetailsBluePrint>
      get getHistoryRequestsListList {
    return [..._historyRequestsList];
  }

  //Add Request////////////////////////////////////////////////

  static Future<void> postRequestParkingDetails(
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
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId.json?auth=$authToken';

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
      singleRecordedRequestDetailsId = responseDecoded['name'];
    } catch (error) {
      rethrow;
    }
  }

//Fetch Request////////////////////////////////////////////////

  static Future<void> fetchRecordedRequests() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<RequestedParkingSlotDetailsBluePrint> schudled = [];
      final List<RequestedParkingSlotDetailsBluePrint> history = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, slotData) {
        if (slotData['status'] == 'pending' ||
            slotData['status'] == 'arrived') {
          schudled.add(
            RequestedParkingSlotDetailsBluePrint(
              requestId: key,
              userId: slotData['userId'],
              paymentMethod: slotData['paymentMethod'],
              endDateTime: slotData['endDateTime'],
              parkingAreaAddressName: slotData['parkingAreaAddressName'],
              parkingSlotId: slotData['parkingSlotId'],
              status: slotData['status'],
              totalCost: slotData['totalCost'],
              startDateTime: slotData['startDateTime'],
              slotLatitude: slotData['destinationLocMap']['latitude'],
              slotLongitude: slotData['destinationLocMap']['longitude'],
            ),
          );
        } else if (slotData['status'] == 'left') {
          history.add(
            RequestedParkingSlotDetailsBluePrint(
              requestId: key,
              userId: slotData['userId'],
              paymentMethod: slotData['paymentMethod'],
              endDateTime: slotData['endDateTime'],
              parkingAreaAddressName: slotData['parkingAreaAddressName'],
              parkingSlotId: slotData['parkingSlotId'],
              status: slotData['status'],
              totalCost: slotData['totalCost'],
              startDateTime: slotData['startDateTime'],
              slotLatitude: slotData['destinationLocMap']['latitude'],
              slotLongitude: slotData['destinationLocMap']['longitude'],
            ),
          );
        }
      });

      _scheduledRequestsList = schudled;
      _historyRequestsList = history;
    } catch (error) {
      throw (error);
    }
  }

//Update Request////////////////////////////////////////////////

  static Future<void> updateRecordedRequest(
      String status, String recordedRequestId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    try {
      await http.patch(
          url, //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'status': status}));
    } catch (error) {
      throw error;
    }
  }

//Delete Request////////////////////////////////////////////////

  static Future<void> cancelRequest() async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$singleRecordedRequestDetailsId.json?auth=$authToken';

    await http.delete(url);
  }

  // static void removeRequestFromList(int index) {
  //   _recordedRequestsList.removeAt(index);
  // }
}
