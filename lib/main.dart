import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/auth_screen.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/Screens/user_profile_screen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/splash_screen.dart';
import 'package:provider/provider.dart';

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

          //....
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, authProviderObj, _) => MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.pink,
              accentColor: Colors.pink,
            ),
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
              ParkingSlotsScreen.routeName: (ctx) => ParkingSlotsScreen(),
              UserProfileScreen.routeName: (ctx) => UserProfileScreen(),
              MapScreen.routeName: (ctx) => MapScreen(),
            },
          ),
        ));
  }
}
