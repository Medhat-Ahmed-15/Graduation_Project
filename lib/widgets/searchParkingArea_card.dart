// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/searchScreen.dart';
import 'package:graduation_project/providers/address_data_provider.dart';

import 'package:provider/provider.dart';

class SearchParkingAreaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
              const Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            stops: [0, 1],
          ),
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
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(SearchScreen.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(
                          width: 10.0,
                        ),
                        const Text('Search parking area')
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
                    Icons.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Provider.of<AddressDataProvider>(context)
                                    .pickUpLocation !=
                                null
                            ? Provider.of<AddressDataProvider>(context)
                                .pickUpLocation
                                .placeName
                            : 'Add Home',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      const Text(
                        'Your living home address',
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
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
