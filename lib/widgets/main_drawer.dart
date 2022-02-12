import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/user_profile_screen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String imgDircetory, String text, BuildContext context,
      Function onTapFunction) {
    return Column(
      children: [
        SizedBox(
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
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white // Theme.of(context).primaryColor,
                ),
          ),
          onTap: onTapFunction,
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 2,
          width: 300,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0.2,
                spreadRadius: 0.2,
                offset: Offset(0.2, 0.2),
              ),
            ],
            color: Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
              padding: const EdgeInsets.all(20),
              height: 200,
              alignment: Alignment
                  .centerLeft, //THIS CONTROLS HOW THE CHILD OF THE CONTAINER IS ALIGNNED
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/person.png',
                    height: 65.0,
                    width: 65.0,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Profile Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white //Theme.of(context).primaryColor
                            ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Visit Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.white //Theme.of(context).primaryColor
                            ),
                      )
                    ],
                  )
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
                  .pushReplacementNamed(UserProfileScreen.routeName);
            }),

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
