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
      title: const Text('Parking Slots'),
    );

    return Scaffold(
        drawer: MainDrawer(),
        appBar: appBar,
        body: Stack(
          children: [
            //Container that is responsible for the background color
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
                //Search Image>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                Container(
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      (0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Container(
                          //   width: 150,
                          //   height: 150,
                          //   child: TextFormField(
                          //     decoration: const InputDecoration(
                          //         labelText: 'Search',
                          //         labelStyle: TextStyle(
                          //           color: Colors.white,
                          //         )),
                          //   ),
                          // ),
                          // Container(
                          //   width: 200,
                          //   height: 200,
                          //   child: Image.asset('assets/images/search.png'),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                //ParkingSlotscard>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                Container(
                  child: ParkingSlotscard(_loadingSpinner),
                  height: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      (0.8),
                ),
              ],
            )
          ],
        ));
  }
}
