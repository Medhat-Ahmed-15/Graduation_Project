import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/parking_slot_blueprint.dart';
import 'package:http/http.dart' as http;

class ParkingSlotsProvider with ChangeNotifier {
  List<ParkingSlotBlueprint> _slots = [];
  final String _authToken;
  ParkingSlotsProvider(this._authToken, this._slots);
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for forwording the list  of slots to anywhere in the project after being fetched from firebase
  List<ParkingSlotBlueprint> get slots {
    return [..._slots];
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for fetching the data from firebase
  Future<void> fetchParkingSlots() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ParkingSlotBlueprint> loadedSlots = [];
      print('Fetched Parking Slots: $extractedData');
      extractedData.forEach((key, slotData) {
        loadedSlots.add(
          ParkingSlotBlueprint(
            sensorDetect: slotData['sensorDetect'],
            gateOpen: slotData['gateOpen'],
            parkedCorrectly: slotData['parkedcorrectly'],
            id: slotData['id'],
            latitude: slotData['latitude'],
            longitude: slotData['longitude'],
            reservationDates:
                slotData['reservationDates'] as Map<String, dynamic>,
            vip: slotData['vip'],
          ),
        );
      });

      // print(loadedSlots[0].availability);
      // print(loadedSlots[0].sensorDetect);
      // print(loadedSlots[0].gateOpen);
      // print(loadedSlots[0].parkedCorrectly);
      // print(loadedSlots[0].id);
      // print(loadedSlots[0].latitude);
      // print(loadedSlots[0].longitude);
      //print(loadedSlots[0].reservationDates);
      // print(loadedSlots[0].vip);
      _slots = loadedSlots;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  //Function for fetching  single parking slot  data from firebase

  Future<ParkingSlotBlueprint> fetchSingleParkingSlotData(
      String parkingSlotId) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$parkingSlotId.json?auth=$_authToken';
    try {
      final response = await http.get(Uri.parse(url));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      print('extractedData $extractedData');

      ParkingSlotBlueprint slotData = ParkingSlotBlueprint(
          id: extractedData['id'],
          latitude: extractedData['latitude'],
          gateOpen: extractedData['gateOpen'],
          parkedCorrectly: extractedData['parkedcorrectly'],
          longitude: extractedData['longitude'],
          sensorDetect: extractedData['sensorDetect'],
          reservationDates: extractedData['reservationDates']
              [currentUserOnline.id],
          vip: extractedData['vip']);

      return (slotData);
    } catch (error) {
      print(error.toString());
    }
  }
}
