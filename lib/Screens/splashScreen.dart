// ignore: file_names
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/signin_screen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/loading_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  AuthProvider authProviderObj;
  SplashScreen(this.authProviderObj);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ColorProvider colorProviderObj;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    return AnimatedSplashScreen(
      backgroundColor: colorProviderObj.generalCardColor,
      centered: true,
      splashIconSize: 250,
      duration: 2500,
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: widget.authProviderObj.checkauthentication() == true
          ? MapScreen()
          : FutureBuilder(
              future: widget.authProviderObj.tryAutoSignIn(),
              builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting
                      ? LoadingScreen()
                      : SigninScreen()),
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset('assets/images/parking.png'),
          ),
          Text(
            'GoPark',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 33,
                fontFamily: 'Yellowtail',
                color: colorProviderObj.textColor),
          ),
        ],
      ),
    );
  }
}
