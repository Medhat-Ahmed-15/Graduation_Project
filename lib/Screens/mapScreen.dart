// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_project/models/argumentsPassedFromBookingScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/providers/request_parkingSlot_details_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/widgets/confirmArrival_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/searchParkingArea_card.dart';
import '../map_key.dart';
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

  ArgumentsPassedFromBookingScreen resultAfterBooking;

//Locating current location
  Future<void> locatePosition() async {
    //get current position

    setState(() {
      loading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    //get latitude and longitude from that position
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);

    //locating camera towards this position
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14);

    //updating the camera position
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //converting latlng to readable addresses
    String address =
        await Provider.of<AddressDataProvider>(context, listen: false)
            .convertToReadableAddress(position);

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

  Future<void> cancelRequest() async {
    if (alreadyCancelled != true) {
      //switching availability
      var sensorDetectSingleSlot =
          await Provider.of<ParkingSlotsProvider>(context, listen: false)
              .fetchSingleParkingSlot(
                  resultAfterBooking.pickedParkingSlotDetails.id);

      if (sensorDetectSingleSlot == false) {
        showDialog(
            context: context,
            //myDIalog is jaust prefix i made it while importing the libraries up
            builder: (BuildContext context) => ProgressDialog(
                  message: 'Cancelling Request',
                ));

        if (isInit == true) {
          //switching availability
          resultAfterBooking.pickedParkingSlotDetails.switchAvailability(
              Provider.of<AuthProvider>(context, listen: false).token,
              'empty',
              'empty',
              'empty');
        }
        isInit = false;

        //Deleting request
        await Provider.of<RequestParkingSlotDetailsProvider>(context,
                listen: false)
            .cancelRequest(context);

        Navigator.pop(context);

        Fluttertoast.showToast(
            msg: 'Request cancelled',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
            textColor: Colors.white,
            fontSize: 16.0);

        resetApp();
      }
    }
  }

  void displayRoute() async {
    if (_isInit == true) {
      if (resultAfterBooking != null) {
        if (resultAfterBooking.flag == 'returned after booking') {
          setState(() {
            showConfirmationCard = true;
            showHamburgerIcon = false;
          });
          await getPlaceDirection();

          cancelRequestTimer = Timer(const Duration(seconds: 15), () {
            if (alreadyCancelled != true) {
              cancelRequest();
            }
          });
        }
      }
    }
    _isInit = false;
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);

    resultAfterBooking = ModalRoute.of(context).settings.arguments
        as ArgumentsPassedFromBookingScreen;

    displayRoute();

    return Scaffold(
      key: scaffoldKey,
      drawer: MainDrawer(),
      appBar: showHamburgerIcon == true
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text("GoPark Map"),
            )
          : null,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => locatePosition(),
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: 300.0),
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
          ),

// *******************************************************Floating Cancel Button ************************************************************************************************************

          //FloatingCancelButton(resultAfterBooking, resetApp, showCancelButton),

// *******************************************************Floating Cancel Button ************************************************************************************************************

          showConfirmationCard == false
              ? SearchParkingAreaCard(getPlaceDirection, loading)
              : ConfirmArrivalCard(resultAfterBooking, resetApp),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AddressDataProvider>(context, listen: false)
        .currentLocation;

    var finalPos = Provider.of<AddressDataProvider>(context, listen: false)
        .destinationLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapKey,
        PointLatLng(initialPos.latitude, initialPos.longitude),
        PointLatLng(finalPos.latitude, finalPos.longitude));

    pLineCoordinates.clear();

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            //So basically, we have done here that now we have a list of latitude and longitude which will allow us to draw a line on map.
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
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

    Marker pickUpMArker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: 'my Location'),
        position: pickUpLatLng,
        markerId: MarkerId('pickUpId'));

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: 'DropOff Location'),
        position: dropOffLatLng,
        markerId: MarkerId('dropOffId'));

    setState(() {
      markersSet.add(pickUpMArker);
      markersSet.add(dropOffLocMarker);
    });
  }
}
