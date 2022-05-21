// ignore_for_file: file_names

import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:graduation_project/Notifications/notifications.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/Screens/searchScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/machine_learning_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../global_variables.dart';

class SearchParkingAreaCard extends StatefulWidget {
  Function getPlaceDirection;
  bool loading;

  SearchParkingAreaCard(this.getPlaceDirection, this.loading);

  @override
  State<SearchParkingAreaCard> createState() => _SearchParkingAreaCardState();
}

class _SearchParkingAreaCardState extends State<SearchParkingAreaCard> {
  bool loading2;

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
                    var result = await Navigator.of(context)
                        .pushNamed(SearchScreen.routeName);

//don't get confused how I returned from returnedFromSinglePrkingSlot.dart with a single pop, I managed the stack of screens using pushNamed and pushNAmedReplacement so that when i return from SinglePrkingSlot I come back to searchParkingArea which is Map screen

                    if (result == 'returnedFromSinglePrkingSlot') {
                      //calling function present in mapScreen

                      widget.getPlaceDirection();
                    }
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
                          : Container(
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
                  setState(() {
                    loading2 = true;
                  });
                  Provider.of<MachineLeraningProvider>(context, listen: false)
                      .machineLearningResult();
                  pickedArea = 'random_area';
                  Navigator.pushNamed(context, ParkingSlotsScreen.routeName);

                  setState(() {
                    loading2 = false;
                  });
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: colorProviderObj.generalCardColor,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.center,
                        child: loading2 == true
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
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
