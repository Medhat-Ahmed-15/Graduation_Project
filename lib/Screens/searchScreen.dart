// ignore_for_file: file_names, missing_return

import 'package:flutter/material.dart';
import 'package:graduation_project/models/placePridictions.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/dividerWidget.dart';
import 'package:graduation_project/widgets/predictionTile.dart';
import 'package:provider/provider.dart';

import '../global_variables.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  bool loading = false;

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorProviderObj.generalCardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Search"),
      ),
      body: Column(
        children: [
          //Container which Contains the  TextFields
          Container(
            margin: const EdgeInsets.all(20),
            height: 215.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.0),
              color: colorProviderObj.genralBackgroundColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10.0,
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
                    children: [
                      Center(
                        child: Text(
                          'Set Destination',
                          style: TextStyle(
                              color: colorProviderObj.textColor,
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
                          ///////////////////////////////////////////////////////////////////////////////////////////////////
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor,
                                blurRadius: 4.0,
                                spreadRadius: 1,
                                offset: const Offset(0.7, 0.7),
                              ),
                            ],
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              color: colorProviderObj.generalCardColor,
                              width: 10,
                              height: 45,
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    pickedCurrentLocation == null
                                        ? 'Please wait...'
                                        : pickedCurrentLocation.placeName,
                                    style: TextStyle(
                                        color: colorProviderObj.textColor),
                                  ),
                                ),
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
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor,
                                blurRadius: 4.0,
                                spreadRadius: 1,
                                offset: const Offset(0.7, 0.7),
                              ),
                            ],
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextField(
                              cursorColor: Theme.of(context).primaryColor,
                              onChanged: (val) async {
                                setState(() {
                                  loading = true;
                                });
                                List<PlacePredictions>
                                    returnedListFromAddressContainer =
                                    await AddressDataProvider.findNearByPlaces(
                                        val);

                                setState(() {
                                  loading = false;
                                  placePredictionList =
                                      returnedListFromAddressContainer;
                                });
                              },
                              controller: dropOffTextEditingController,
                              style:
                                  TextStyle(color: colorProviderObj.textColor),
                              decoration: InputDecoration(
                                hintText: 'Where to',
                                hintStyle: TextStyle(
                                    color: colorProviderObj.textColor),
                                fillColor: colorProviderObj.generalCardColor,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
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
          //Expanded(child: Container()),
          //displaying predicted places
          placePredictionList.isNotEmpty
              ? loading == true
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16.0),
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return PredictionTile(
                              currentPlacePredicted:
                                  placePredictionList[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return DividerWidget();
                        },
                        itemCount: placePredictionList.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                      ),
                    )
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 100),
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/search.png"),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
