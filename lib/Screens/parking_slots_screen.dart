import 'package:flutter/material.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:graduation_project/widgets/parking_slots_card.dart';
import 'package:provider/provider.dart';

class ParkingSlotsScreen extends StatefulWidget {
  static const routeName = '/parkingSlotsScreen';

  @override
  State<ParkingSlotsScreen> createState() => _ParkingSlotsScreenState();
}

class _ParkingSlotsScreenState extends State<ParkingSlotsScreen> {
  var _isInit = true;
  bool _loadingSpinner = true;

  @override
  void didChangeDependencies() {
    //  and now here we shouldn't use async await here for didChangeDependencies or for initState because these are not methods which return futures  normally and since you override the built-in methods, you shouldn't change what they return. So using async here would change what they return because an async method always returns a future and  therefore, don't use async await here but here, I will use the old approach with then
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });
      Provider.of<ParkingSlotsProvider>(context)
          .fetchParkingSlots()
          .then((_) => setState(() {
                _loadingSpinner = false;
              }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Choose you slot'),
    );

    return Scaffold(
        drawer: MainDrawer(),
        appBar: appBar,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [
                //     Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                //     Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                //   ],
                //   begin: Alignment.topLeft,
                //   end: Alignment.topRight,
                //   stops: [0, 1],
                // ),
                color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 250,
                height: 250,
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
        ));
  }
}
