import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParkingSlotBlueprint {
  String id;
  bool availability;
  bool vip;
  bool sensorDetect;
  String startDateTtime;
  String endDateTime;
  double latitude;
  double longitude;
  String userId;

  ParkingSlotBlueprint(
      {this.id,
      this.availability,
      this.startDateTtime,
      this.latitude,
      this.longitude,
      this.vip,
      this.sensorDetect,
      this.endDateTime,
      this.userId});
}
