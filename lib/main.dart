import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graduation_project/Screens/bookingSlotScreen.dart';
import 'package:graduation_project/Screens/complete_profile_screen.dart';
import 'package:graduation_project/Screens/congratulations_screen.dart';
import 'package:graduation_project/Screens/easyToUseScreen.dart';
import 'package:graduation_project/Screens/getHelpScreen.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/parking_slots_screen.dart';
import 'package:graduation_project/Screens/saveTime_screen%20.dart';
import 'package:graduation_project/Screens/settings_screen.dart';
import 'package:graduation_project/Screens/tabs_screen.dart';
import 'package:graduation_project/Screens/tipScreen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
import 'package:graduation_project/widgets/loading_screen.dart';
import 'package:provider/provider.dart';
import 'Screens/saveMoney_screen.dart';
import 'Screens/searchScreen.dart';
import 'Screens/signin_screen.dart';
import 'Screens/signup_screen.dart';
import 'Screens/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  Stripe.publishableKey =
      'pk_test_51KuxNhHCnZqk0tlCtoEMfNpRrhxN9gwRopxB2U8U8uvhTWATPU7Wf7KAwzqv92WnCDS6Y2Zkbdci535s7IQPDOeq00q30zNGJ9';

  await AwesomeNotifications().initialize(
    'resource://drawable/parking',
    [
      //User didn't come to the slot Notification channel **************************************************************************

      NotificationChannel(
        channelKey:
            'goPark', //used to connect our notifications to the specific channels
        channelName:
            'GoPark', //will be displayed in Android's app’s notification settings.
        defaultColor: const Color.fromRGBO(33, 147, 176, 255).withOpacity(1),
        importance: NotificationImportance
            .High, //to make sure that when our notification is displayed, it peeks out from the top of the screen
        channelShowBadge: true,
        //soundSource: 'resource://raw/res_custom_notification',
      ),
    ],
  );

  runApp(MyApp());

  await AndroidAlarmManager.initialize();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //Providing all Theme Colors Data
          ChangeNotifierProvider(
            create: (context) => ColorProvider(),
          ),

          //....

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
              primaryColor: Color.fromRGBO(241, 101, 115, 1).withOpacity(1),
              accentColor: Color.fromRGBO(241, 101, 115, 1).withOpacity(1),
            ),
            debugShowCheckedModeBanner:
                false, //if i make true it will display that this application is in debug model plus hathot el debug banner el bayb2 fal top right corner of the screen ,false hatsheel el debug banner
            home: SplashScreen(authProviderObj),
            routes: {
              CongratulationsScreen.routeName: (ctx) => CongratulationsScreen(),
              SigninScreen.routeName: (ctx) => SigninScreen(),
              SaveMoneyScreen.routeName: (ctx) => SaveMoneyScreen(),
              SaveTimeScreen.routeName: (ctx) => SaveTimeScreen(),
              EasyToUseScreen.routeName: (ctx) => EasyToUseScreen(),
              TipScreen.routeName: (ctx) => TipScreen(),
              MapScreen.routeName: (ctx) => MapScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
              ParkingSlotsScreen.routeName: (ctx) => ParkingSlotsScreen(),
              BookingSlotScreen.routeName: (ctx) => BookingSlotScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              SignupScreen.routeName: (ctx) => SignupScreen(),
              CompleteProfileScreen.routeName: (ctx) => CompleteProfileScreen(),
              TabsScreen.routeName: (ctx) => TabsScreen(),
              GetHelpScreen.routeName: (ctx) => GetHelpScreen(),
            },
          ),
        ));
  }
}
