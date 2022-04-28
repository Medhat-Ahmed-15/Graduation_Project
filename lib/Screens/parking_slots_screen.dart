import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/parking_slots_card.dart';
import 'package:provider/provider.dart';

import '../global_variables.dart';

class ParkingSlotsScreen extends StatefulWidget {
  static const routeName = '/parkingSlotsScreen';

  @override
  State<ParkingSlotsScreen> createState() => _ParkingSlotsScreenState();
}

class _ParkingSlotsScreenState extends State<ParkingSlotsScreen> {
  var _isInit = true;
  String area;
  bool _loadingSpinner = true;

  @override
  void didChangeDependencies() {
    //  and now here we shouldn't use async await here for didChangeDependencies or for initState because these are not methods which return futures  normally and since you override the built-in methods, you shouldn't change what they return. So using async here would change what they return because an async method always returns a future and  therefore, don't use async await here but here, I will use the old approach with then
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });

      if (pickedArea == 'Alexandria Sporting Club' ||
          pickedArea == 'Smouha Sporting Club') {
        area = 'Parking_Slots';
      } else if (pickedArea == 'random_area') {
        area = 'Parking Slots Random Area';
      }

      Provider.of<ParkingSlotsProvider>(context)
          .fetchParkingSlots(area)
          .then((_) => setState(() {
                _loadingSpinner = false;
              }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  Future<void> _refrefreshScreen() async {
    await Provider.of<ParkingSlotsProvider>(context, listen: false)
        .fetchParkingSlots(area)
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Choose you slot'),
    );

    return Scaffold(
        backgroundColor: colorProviderObj.generalCardColor,
        drawer: MainDrawer(),
        appBar: appBar,
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: colorProviderObj.genralBackgroundColor,
          strokeWidth: 5,
          edgeOffset: 0,
          onRefresh: _refrefreshScreen,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.height.round() <= 781
                      ? 180
                      : 250,
                  height: MediaQuery.of(context).size.height.round() <= 781
                      ? 180
                      : 250,
                  margin: EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/parkingSlotsArea.png"),
                    ),
                  ),
                ),
              ),
              ParkingSlotscard(_loadingSpinner)
            ],
          ),
        ));
  }
}
