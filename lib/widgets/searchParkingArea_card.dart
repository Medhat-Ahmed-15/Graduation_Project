// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/searchScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';

import 'package:provider/provider.dart';

class SearchParkingAreaCard extends StatelessWidget {
  Function getPlaceDirection;
  bool loading;
  SearchParkingAreaCard(this.getPlaceDirection, this.loading);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        height: 300,
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

          color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
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
              const Text(
                'Where to? ',
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Brand-semibold',
                    color: Colors.white),
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

                      getPlaceDirection();
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
                      loading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : Text(
                              Provider.of<AddressDataProvider>(context)
                                          .currentLocation !=
                                      null
                                  ? Provider.of<AddressDataProvider>(context)
                                      .currentLocation
                                      .placeName
                                  : 'Add Home',
                              style: TextStyle(color: Colors.white),
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
              const SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
