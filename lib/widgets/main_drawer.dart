import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/Screens/user_profile_screen.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(IconData icon, String text, BuildContext context,
      Function onTapFunction) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onTap: onTapFunction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.pink,
              padding: const EdgeInsets.all(20),
              height: 200,
              alignment: Alignment
                  .centerLeft, //THIS CONTROLS HOW THE CHILD OF THE CONTAINER IS ALIGNNED
              // child: Text(
              //   'Cooking Up!',
              //   style: TextStyle(
              //       color: Theme.of(context).primaryColor,
              //       fontWeight: FontWeight.w900,
              //       fontSize: 30),
              // ),
            ),
            const SizedBox(height: 20),

            //>>
            buildListTile(Icons.home, 'Home', context, () {
              Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
            }),

            //>>
            buildListTile(Icons.settings, 'Settings', context, () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProfileScreen.routeName);
            }),

            //>>
            buildListTile(Icons.help_outline, 'Get help', context, () {}),

            //>>
            buildListTile(Icons.info_outline, 'About app', context, () {}),

            //>>
            buildListTile(Icons.exit_to_app, 'Signout', context, () {
              Navigator.of(context).pop(context);
              Navigator.of(context).pushReplacementNamed(
                  '/'); // inthestructor recommend always go to slash, slash nothing and that is the home route. Since you always go there, you ensure that this logic here in the main.dart file will always run whenever the logout button is pressed and since this always runs and since this home route is always loaded, we will always end up on the AuthScreen when we clear our data in the logout method of the auth provider. So simply add this additional line here and go to your home route to ensure that you never have unexpected behaviors when logging out.
              Provider.of<AuthProvider>(context, listen: false).SignOut();
            }),
          ],
        ),
      ),
    );
  }
}
