import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/providers/parking_slot_blueprint_provider.dart';
import 'package:http/http.dart' as http;

class ParkingSlotsProvider with ChangeNotifier {
  List<ParkingSlotBlueprintProvider> _slots = [];
  final String _authToken;
  ParkingSlotsProvider(this._authToken, this._slots);
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for forwording the list  of slots to anywhere in the project after being fetched from firebase
  List<ParkingSlotBlueprintProvider> get slots {
    return [..._slots];
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for fetching the data from firebase
  Future<void> fetchParkingSlots() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots.json?auth=$_authToken';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ParkingSlotBlueprintProvider> loadedSlots = [];
      extractedData.forEach((key, slotData) {
        loadedSlots.add(
          ParkingSlotBlueprintProvider(
              availability: slotData['availability'],
              id: slotData['id'],
              longitude: slotData['longitude'],
              latitude: slotData['latitude'],
              startDateTtime: slotData['start_time'],
              endDateTime: slotData['end_time'],
              userId: slotData['userId']),
        );
      });
      _slots = loadedSlots;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  //Function for fetching the data from firebase
  Future<void> updateParkingSlot(String slotId,
      ParkingSlotBlueprintProvider parkingSlotBlueprintProvider) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Parking_Slots/$slotId.json?auth=$_authToken';
    try {
      final response = await http.patch(url,
          body: json.encode({
            'availability': parkingSlotBlueprintProvider.availability,
            'id': parkingSlotBlueprintProvider.id,
            'longitude': parkingSlotBlueprintProvider.longitude,
            'latitude': parkingSlotBlueprintProvider.latitude,
            'start_time': parkingSlotBlueprintProvider.startDateTtime,
            'end_time': parkingSlotBlueprintProvider.endDateTime,
            'userId': parkingSlotBlueprintProvider.userId
          }));
    } catch (error) {
      throw (error);
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

}
