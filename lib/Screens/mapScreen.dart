// ignore_for_file: file_names

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/widgets/floatingHamburgerButton.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/searchParkingArea_card.dart';
import '../map_key.dart';
import 'package:dialogs/dialogs.dart';
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
  bool showCancelButton = false;

  //The main difference between List and Set is that Set is unordered and contains different elements, whereas the list is ordered and can contain the same elements in it.
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double bottomPaddingOfMap = 0;

//Locating current location
  Future<void> locatePosition(BuildContext context) async {
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
            .convertToReadableAddress(position, context);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultAfterBooking =
        ModalRoute.of(context).settings.arguments as String;

    if (resultAfterBooking == 'returned after booking') {
      showCancelButton = true;
      getPlaceDirection();
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: MainDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("GoPark Map"),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => locatePosition(context),
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
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

                setState(() {
                  bottomPaddingOfMap = 300.0;
                });

                locatePosition(context);
              },
            ),
          ),
          showCancelButton == true
              ? FloatingCancelButton(scaffoldKey)
              : const Text(''),
          SearchParkingAreaCard(getPlaceDirection, loading)
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AddressDataProvider>(context, listen: false).pickUpLocation;

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

    setState(() {
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
    });

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
