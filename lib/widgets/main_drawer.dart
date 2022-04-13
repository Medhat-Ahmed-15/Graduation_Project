import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/history_screen.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/settings_screen.dart';
import 'package:graduation_project/Screens/user_profile_screen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String imgDircetory, String text, BuildContext context,
      Function onTapFunction) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        ListTile(
          leading: Container(
            width: 35,
            height: 35,
            child: Image.asset(imgDircetory),
          ),
          title: Text(
            text,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorProviderObj.textColor),
          ),
          onTap: onTapFunction,
        ),
        Divider(
          color: colorProviderObj.genralBackgroundColor,
          thickness: 1,
        ),
      ],
    );
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: colorProviderObj.generalCardColor,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: colorProviderObj.genralBackgroundColor,
              padding: const EdgeInsets.all(20),
              height: 200,
              alignment: Alignment
                  .centerLeft, //THIS CONTROLS HOW THE CHILD OF THE CONTAINER IS ALIGNNED
              child: Row(
                children: [
                  Container(
                    height: 100,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorProviderObj.generalCardColor,
                          radius: 40,
                          child: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30,
                            backgroundImage: AssetImage(
                              'assets/images/person.png',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(
                                UserProfileScreen.routeName);
                          },
                          child: Text(
                            'Visit Profile',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Theme.of(context).primaryColor),
                      ),
                      Container(
                        width: 160,
                        child: Text(
                          currentUserOnline.name.split(' ')[0],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: colorProviderObj.textColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //>>
            buildListTile('assets/images/home.png', 'Home', context, () {
              Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
            }),

            //>>
            buildListTile('assets/images/setting.png', 'Settings', context, () {
              Navigator.of(context)
                  .pushReplacementNamed(SettingsScreen.routeName);
            }),

            //>>
            buildListTile(
                'assets/images/history.png',
                'History',
                context,
                // () {
                //   Navigator.of(context)
                //       .pushReplacementNamed(HistoryScreen.routeName);
                // },
                null),

            //>>
            buildListTile(
                'assets/images/information.png', 'About app', context, () {}),

            //>>
            buildListTile('assets/images/help.png', 'Get help', context, () {}),

            //>>
            buildListTile('assets/images/exit.png', 'Signout', context, () {
              Navigator.of(context).pop(context);
              Navigator.of(context).pushReplacementNamed(
                  '/'); //   always go to slash, slash nothing and that is the home route. Since you always go there, you ensure that this logic here in the main.dart file will always run whenever the logout button is pressed and since this always runs and since this home route is always loaded, we will always end up on the AuthScreen when we clear our data in the logout method of the auth provider. So simply add this additional line here and go to your home route to ensure that you never have unexpected behaviors when logging out.
              Provider.of<AuthProvider>(context, listen: false).SignOut();
            }),
          ],
        ),
      ),
    );
  }
}
