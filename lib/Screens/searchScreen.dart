// ignore_for_file: file_names, missing_return

import 'package:flutter/material.dart';
import 'package:graduation_project/models/placePridictions%20copy.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/widgets/dividerWidget.dart';
import 'package:graduation_project/widgets/predictionTile.dart';
import 'package:provider/provider.dart';

import '../map_key.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:eg';

      var res = await Provider.of<AddressDataProvider>(context, listen: false)
          .getRequest(autoCompleteUrl);

      if (res == "failed") {
        return;
      }

      if (res['status'] == 'OK') {
        var predictions = res['predictions'];

//to convert the json file which contain list of maps to normal list
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromjson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var objAddressDataProvider = Provider.of<AddressDataProvider>(context);

    pickUpTextEditingController.text =
        objAddressDataProvider.pickUpLocation == null
            ? ''
            : objAddressDataProvider.pickUpLocation.placeName;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Search"),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                    Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: [0, 1],
                ),
              ),
            ),
            Column(
              children: [
                //Container which Contains the  TextFields
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 215.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 3.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5.0,
                        ),
                        Stack(
                          children: const [
                            Center(
                              child: Text(
                                'Set Destination',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/pickicon.png',
                              height: 20.0,
                              width: 20.0,
                            ),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextField(
                                    controller: pickUpTextEditingController,
                                    decoration: const InputDecoration(
                                      hintText: 'Pickup Location',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 8.0, bottom: 8.0),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/desticon.png',
                              height: 20.0,
                              width: 20.0,
                            ),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextField(
                                    onChanged: (val) {
                                      findPlace(val);
                                    },
                                    controller: dropOffTextEditingController,
                                    decoration: const InputDecoration(
                                      hintText: 'Where to',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 8.0, bottom: 8.0),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                //displaying predicted places
                placePredictionList.length > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(0.0),
                          itemBuilder: (context, index) {
                            return PredictionTile(
                                placePredictions: placePredictionList[index]);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return DividerWidget();
                          },
                          itemCount: placePredictionList.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                        ),
                      )
                    : Container()
              ],
            ),
          ],
        ));
  }
}
