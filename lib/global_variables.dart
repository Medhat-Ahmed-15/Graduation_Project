import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_project/models/UserInfo.dart';
import 'package:graduation_project/models/parking_slot_blueprint.dart';

import 'models/address.dart';

String mapKey = 'AIzaSyBR8Aa517A9PjaHoBphSVJgiGs_7745HyQ';
String pickedArea;
UserInfo currentUserOnline;

Address pickedCurrentLocation;
Address pickedparkingSlotAreaLocation;
Address pickedParkingSlotLocation;

ParkingSlotBlueprint pickedParkingSlot;

String authToken;
String currentUserId;
String singleRecordedRequestDetailsId;
String reservedDateTimeResponseKey;
LatLng userCurrentLocation;
String recommendedId = '';
BuildContext signInContext;
BuildContext mainDrawerContext;
BuildContext mapScreenContext;
