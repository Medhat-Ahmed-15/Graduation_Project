// ignore_for_file: file_names

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/widgets/dividerWidget.dart';
import 'package:graduation_project/widgets/progressDialog.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/widgets/floatingHamburgerButton.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/searchParkingArea_card.dart';

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

  double bottomPaddingOfMap = 0;

//Locating current location
  void locatePosition() async {
    //get current position
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("GoPark Map"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();
            },
          ),
          //FloatingHamburgerButton(scaffoldKey),
          SearchParkingAreaCard(getPlaceDirection)
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AddressDataProvider>(context, listen: false).pickUpLocation;

    var finalPos = Provider.of<AddressDataProvider>(context, listen: false)
        .dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Please wait...',
            ));

    var details = await Provider.of<AddressDataProvider>(context, listen: false)
        .obtainPlaceDirectionDetailsBetweenTwoPoints(
            pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print('This is Encoded Points ::');
    print(details.encodedPoints);
  }
}
