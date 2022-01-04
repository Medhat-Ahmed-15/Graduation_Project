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
              availability: slotData['availability'], id: slotData['id']),
        );
      });
      _slots = loadedSlots;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

}
