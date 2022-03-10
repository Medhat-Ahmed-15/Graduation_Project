import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MachineLeraningProvider with ChangeNotifier {
  //List<String> recommendedSlots = [];

  // Future<void> sendCurrentLocation(Position position) async {
  //   //url to send the post request to
  //   final url = 'http://10.0.2.2:5000/name';

  //   //sending a post request to the url
  //   final response = await http.post(Uri.parse(url),
  //       body: json.encode({
  //         'name':
  //             '${position.latitude.toString()},${position.longitude.toString()}'
  //       }));
  // }

  // Future<void> machineLearningResult() async {
  //   //url to get data after processing
  //   final response = await http.get(Uri.parse('http://10.0.2.2:5000/name'));

  //   //converting the fetched data from json to key value pair that can be displayed on the screen
  //   final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
  //   print(decodedResponse);

  //   var recommendedIdSlotsList = (decodedResponse as List).map((index) {
  //     recommendedSlots.add(index[1].toString());
  //     print('index' + ' ' + index[1].toString());
  //   }).toList();
  // }
}
