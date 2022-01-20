import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/address.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../map_key.dart';

class AddressDataProvider extends ChangeNotifier {
  Address pickUpLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  Future<dynamic> getRequest(String url) async {
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        String jSonData = response.body;
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      } else {
        return "failed";
      }
    } catch (exp) {
      return "failed";
    }
  }

  Future<String> convertToReadableAddress(
      Position position, BuildContext context) async {
    String placeAddress = "";

    String placeAddress1;
    String placeAddress2;
    String placeAddress3;
    String placeAddress4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await getRequest(url);

    if (response != "failed") {
      // placeAddress = response["results"][0][
      //     "formatted_address"]; //since the formatted address displays the specific address of the current location and this is risky regarding the security
      placeAddress1 =
          response["results"][0]["address_components"][0]["long_name"];
      placeAddress2 =
          response["results"][0]["address_components"][2]["long_name"];
      placeAddress4 =
          response["results"][0]["address_components"][5]["long_name"];

      placeAddress =
          placeAddress1 + ", " + placeAddress2 + ", " + placeAddress4;

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }
}
