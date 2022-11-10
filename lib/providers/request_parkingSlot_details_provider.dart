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
      bool vip,
      Map destinationLocMap}) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId.json?auth=$authToken';

    try {
      var response = await http.post(
        Uri.parse(url),
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
            'rate': 'empty',
            'status': status,
            'vip': vip
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
      final response = await http.get(Uri.parse(url));
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
              vip: slotData['vip'],
              rate: slotData['rate'],
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
              vip: slotData['vip'],
              rate: slotData['rate'],
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
      rethrow;
    }
  }

  //Check If The User Is Still In A Previous Reservation before booking a new one ////////////////////////////////////////////////

  static Future<bool> checkUserStatusBeforeBooking() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        print('FAAAAADDDEEEEE');
        return true;
      }
      int counter = 0;
      extractedData.forEach(
        (key, slotData) {
          if (slotData['status'] != 'left') {
            counter++;
          }
        },
      );

      if (counter > 0) {
        return false;
      } else {
        return true;
      }
    } catch (error) {
      print('Check User Status Before Booking Error1 :: $error');
      rethrow;
    }
  }

//Update Status In Recorded Request////////////////////////////////////////////////

  static Future<void> updateStatusInRecordedRequest(
      String status, String recordedRequestId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    try {
      await http.patch(
          Uri.parse(
              url), //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'status': status}));
    } catch (error) {
      rethrow;
    }
  }

  //Update Status In Recorded Request////////////////////////////////////////////////

  static Future<void> updateRateInRecordedRequest(
      String rate, String recordedRequestId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    try {
      await http.patch(
          Uri.parse(
              url), //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'rate': rate}));
    } catch (error) {
      rethrow;
    }
  }

  //Update end time In Recorded Request////////////////////////////////////////////////

  static Future<void> updateEndTimeInRecordedRequest(
      String endDateTime, String recordedRequestId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    try {
      await http.patch(
          Uri.parse(
              url), //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'endDateTime': endDateTime}));
    } catch (error) {
      print('Update EndTime In Recorded Request Error 1 :: $error');
      rethrow;
    }
  }

  //Update Cost In Recorded Request////////////////////////////////////////////////

  static Future<void> updateCostInRecordedRequest(
      int cost, String recordedRequestId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequestId.json?auth=$authToken';

    try {
      await http.patch(
          Uri.parse(
              url), //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({'totalCost': cost}));
    } catch (error) {
      rethrow;
    }
  }

//Delete Request////////////////////////////////////////////////

  static Future<void> deleteRecordedRequestDetatils(
      String recordedRequstId) async {
    final String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking-Slots-Request-Details/$currentUserId/$recordedRequstId.json?auth=$authToken';

    await http.delete(Uri.parse(url));

    _scheduledRequestsList
        .removeWhere((element) => element.requestId == recordedRequstId);
  }

  // static void removeRequestFromList(int index) {
  //   _recordedRequestsList.removeAt(index);
  // }
}
