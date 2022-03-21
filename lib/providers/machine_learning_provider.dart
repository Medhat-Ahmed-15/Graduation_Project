import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'parking_slot_blueprint_provider.dart';

class MachineLeraningProvider with ChangeNotifier {
  List<String> recommendedSlotsIds = [];

  List<String> get recommendedIds {
    return [...recommendedSlotsIds];
  }

  Future<void> sendCurrentLocation(Position position) async {
    //url to send the post request to
    final url = 'http://10.0.2.2:5000/name';

    //sending a post request to the url
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'name':
              '${position.latitude.toString()},${position.longitude.toString()}'
        }));
  }

  Future<void> machineLearningResult() async {
    List<String> recommendedSlots = [];
    //url to get data after processing
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/name'));

    //converting the fetched data from json to key value pair that can be displayed on the screen
    final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
    String result = decodedResponse['name'].toString();

    String updatedResult = result.substring(1, result.length - 1);

    //   "], ["
    List<String> updatedResult2 = updatedResult.split("], [");

    for (int i = 0; i < updatedResult2.length; i++) {
      if (updatedResult2[i].contains("]")) {
        recommendedSlots.add(updatedResult2[i].replaceAll("]", ""));
        break;
      }

      recommendedSlots.add(updatedResult2[i]);
    }

    for (int i = 0; i < recommendedSlots.length; i++) {
      recommendedSlotsIds.add(recommendedSlots[i].split(',')[1].trim());
      print(recommendedSlotsIds[i]);
    }
  }
}
