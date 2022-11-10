// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/Screens/searchScreen.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/sorryDialog.dart';
import 'package:graduation_project/widgets/userBlockedDialog.dart';
import 'package:provider/provider.dart';
import '../global_variables.dart';

class SearchParkingAreaCard extends StatefulWidget {
  // Function getPlaceDirection;
  bool loading;

  SearchParkingAreaCard(this.loading);

  @override
  State<SearchParkingAreaCard> createState() => _SearchParkingAreaCardState();
}

class _SearchParkingAreaCardState extends State<SearchParkingAreaCard> {
  bool loading2 = false;

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
          //     const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.topRight,
          //   stops: [0, 1],
          // ),

          color: colorProviderObj.generalCardColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 16.0,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 6.0,
              ),
              Text(
                'Hi there, ',
                style: TextStyle(
                    fontSize: 12.0, color: Theme.of(context).primaryColor),
              ),
              Text(
                'Where to? ',
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Brand-semibold',
                    color: colorProviderObj.textColor),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                decoration: BoxDecoration(
                  // boxShadow: const [
                  //   BoxShadow(
                  //     color: Colors.pink,
                  //     blurRadius: 4.0,
                  //     spreadRadius: 1,
                  //     offset: Offset(0.7, 0.7),
                  //   ),
                  // ],
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: FlatButton(
                  onPressed: () async {
                    recommendedId =
                        ''; //3ashan 2admn 2n msh mashee fal process bata3t park now
                    if (currentUserOnline.wrongUse >= 10) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) => UserBlockedDialog(),
                      );
                    } else {
                      var result = await Navigator.of(context)
                          .pushNamed(SearchScreen.routeName);
                    }

//don't get confused how I returned from returnedFromSinglePrkingSlot.dart with a single pop, I managed the stack of screens using pushNamed and pushNAmedReplacement so that when i return from SinglePrkingSlot I come back to searchParkingArea which is Map screen

                    // if (result == 'returnedFromSinglePrkingSlot') {
                    //   //calling function present in mapScreen

                    //   widget.getPlaceDirection();
                    // }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          'Search parking area',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(1),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.loading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : SizedBox(
                              width: 200,
                              child: Text(
                                pickedCurrentLocation != null
                                    ? pickedCurrentLocation.placeName
                                    : 'Add Home',
                                style: TextStyle(
                                    color: colorProviderObj.textColor),
                              ),
                            ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        'Your current location ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12.0),
                      ),
                    ],
                  )
                ],
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              FlatButton(
                onPressed: () async {
                  try {
                    setState(() {
                      loading2 = true;
                    });
                    String currentLocation =
                        '${userCurrentLocation.longitude},${userCurrentLocation.latitude}';
                    var response =
                        await machineLearningProcess(currentLocation);

                    Address address = Address();
                    address.placeName = 'Alexandria Sporting Club';
                    address.placeId = 'ChIJdfXbQYnE9RQRhLHmynPh4PU';
                    address.latitude = 31.2127696;
                    address.longitude = 29.9333728;

                    pickedparkingSlotAreaLocation = address;

                    if (response.values.first == true) {
                      showDialog(
                          context: context,
                          barrierColor: Colors.white24,
                          builder: (BuildContext context) => SorryDialog(
                              'Sorry there isn\'nt any recommended slots currently'));
                    } else {
                      Navigator.pushNamed(
                          context, ParkingSlotsScreen.routeName);
                    }

                    setState(() {
                      loading2 = false;
                    });
                  } on SocketException catch (error) {
                    print(error.message);
                  }
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 200,
                    height: 50,
                    margin: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: colorProviderObj.generalCardColor,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.center,
                        child: loading2 == true
                            ? Center(
                                child: LinearProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                  backgroundColor:
                                      colorProviderObj.generalCardColor,
                                ),
                              )
                            : Text(
                                'Park Now',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
