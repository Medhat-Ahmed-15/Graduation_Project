import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/auth_screen.dart';
import 'package:graduation_project/Screens/bookingSlotScreen.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/Screens/user_profile_screen.dart';
import 'package:graduation_project/models/address.dart';
import 'package:graduation_project/providers/address_data_provider.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/splash_screen.dart';
import 'package:provider/provider.dart';

import 'Screens/searchScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //Providing Auth Data
          ChangeNotifierProvider(
            create: (ctx) => AuthProvider(),
          ),

          //Providing parking slots  Data
          ChangeNotifierProxyProvider<AuthProvider, ParkingSlotsProvider>(
            create: (ctx) => ParkingSlotsProvider('', []),
            update: (ctx, authProviderObj, previusParkingSlotsProviderObj) =>
                ParkingSlotsProvider(authProviderObj.token,
                    previusParkingSlotsProviderObj.slots),
          ),

          //Providing all address Data
          ChangeNotifierProvider(
            create: (context) => AddressDataProvider(),
          ),

          //....
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, authProviderObj, _) => MaterialApp(
            builder: (context, child) => MediaQuery(

                //*Just for convertinf the time picker to be 24H instead of 12 H
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child),
            //*Just for convertinf the time picker to be 24H instead of 12 H

            theme: ThemeData(
              primarySwatch: Colors.pink,
              accentColor: Colors.pink,
            ),
            debugShowCheckedModeBanner:
                true, //if i make true it will display that this application is in debug model plus hathot el debug banner el bayb2 fal top right corner of the screen ,false hatsheel el debug banner
            home: authProviderObj.checkauthentication() == true
                ? MapScreen()
                : FutureBuilder(
                    future: authProviderObj.tryAutoSignIn(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              UserProfileScreen.routeName: (ctx) => UserProfileScreen(),
              MapScreen.routeName: (ctx) => MapScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
              ParkingSlotsScreen.routeName: (ctx) => ParkingSlotsScreen(),
              BookingSlotScreen.routeName: (ctx) => BookingSlotScreen(),
            },
          ),
        ));
  }
}
