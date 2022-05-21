// ignore_for_file: file_names

import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/confirmArrival_card.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/searchParkingArea_card.dart';
import '../global_variables.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/MapScreen';
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position currentPosition;
  var geoLocator = Geolocator();
  bool loading = false;
  bool showConfirmationCard = false;
  bool showHamburgerIcon = true;

  //The main difference between List and Set is that Set is unordered and contains different elements, whereas the list is ordered and can contain the same elements in it.
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double bottomPaddingOfMap = 0;
  bool _isInit = true;
  bool isInit = true;
  bool alreadyCancelled = false;

  Timer cancelRequestTimer;

  String flag;

//Locating current location
  Future<void> locatePosition() async {
    //get current position

    setState(() {
      loading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    //get latitude and longitude from that position
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);

    //locating camera towards this position
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14);

    //updating the camera position
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //converting latlng to readable addresses

    await AddressDataProvider.convertToReadableAddress(position);

//sending to Machine Learning current position

    // await Provider.of<MachineLeraningProvider>(context, listen: false)
    //     .sendCurrentLocation(position);

    setState(() {
      loading = false;
    });
  }

  resetApp() async {
    alreadyCancelled = true;
    setState(() {
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
      showConfirmationCard = false;
      showHamburgerIcon = true;
    });

    locatePosition();
  }

  void displayRoute() async {
    if (_isInit == true) {
      if (flag != null) {
        if (flag == 'coming from tabs screen') {
          setState(() {
            showConfirmationCard = true;
            showHamburgerIcon = false;
          });
          await getPlaceDirection();

          cancelRequestTimer = Timer(const Duration(seconds: 500), () {
            if (alreadyCancelled != true) {
              //cancelRequest();
            }
          });
        }
      }
    }
    _isInit = false;
  }

  void cancelTheTimer() {
    cancelRequestTimer.cancel();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  //Notification********************************************************************************************************************
  @override
  void initState() {
    super.initState();

    //this request for enebling notifications is mainly for ios users since the default in ios is that it is disabled unlike android
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allow Notifications'),
              content:
                  const Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
//A createdStream transports ReceivedNotification objects when notifications are created. In other words, if you press the “View Orders” button a notification will be created and you can listen to the createdStream to get the ReceivedNotification object and do something with it. The ReceivedNotification object holds all kinds of information about your notification.
    AwesomeNotifications().createdStream.listen((notification) {
      print('Notification created ${notification.channelKey}');
    });
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);

    flag = ModalRoute.of(context).settings.arguments as String;

    displayRoute();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      drawer: MainDrawer(),
      appBar: showHamburgerIcon == true
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text("GoPark Map"),
            )
          : null,
      body: WillPopScope(
        onWillPop: () async =>
            false, //this line is for avoiding the user to go to the previous page when he is in the map screen
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: 350.0),
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              markers: markersSet,
              circles: circlesSet,
              polylines: polyLineSet,
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                locatePosition();
              },
            ),

            // *******************************************************Floating Cancel Button ************************************************************************************************************

            //FloatingCancelButton(resultAfterBooking, resetApp, showCancelButton),

            // *******************************************************Floating Cancel Button ************************************************************************************************************

            showConfirmationCard == false
                ? SearchParkingAreaCard(getPlaceDirection, loading)
                : ConfirmArrivalCard(flag, resetApp, cancelTheTimer),
          ],
        ),
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = pickedCurrentLocation;

    var finalPos = pickedParkingSlotLocation;

    print('initialPos:   ${initialPos.latitude}   ${initialPos.longitude}');
    print('finalPos:   ${finalPos.latitude}   ${finalPos.longitude}');

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapKey,
        PointLatLng(initialPos.latitude, initialPos.longitude),
        PointLatLng(finalPos.latitude, finalPos.longitude));

    pLineCoordinates.clear();

    if (result.points.isNotEmpty) {
      for (var pointLatLng in result.points) {
        pLineCoordinates
            //So basically, we have done here that now we have a list of latitude and longitude which will allow us to draw a line on map.
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();

//Now we have to create an instance of the fully line and we have to pass the required parameters to it in order to redraw the polyline.

    Polyline polyline = Polyline(
        color: Theme.of(context).primaryColor,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true);

//but before we add a new one we have to make it clear that polyline is empty when ever we add a polyline to polyline set that why I cleared the set and aslo the list
    polyLineSet.add(polyline);

//showayt tazbeetat for animating the camera when drawing the line
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker initLoc = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: 'my Location'),
        position: pickUpLatLng,
        markerId: MarkerId('pickUpId'));

    Marker finalLoc = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: 'DropOff Location'),
        position: dropOffLatLng,
        markerId: MarkerId('dropOffId'));

    setState(() {
      markersSet.add(initLoc);
      markersSet.add(finalLoc);
    });
  }
}
