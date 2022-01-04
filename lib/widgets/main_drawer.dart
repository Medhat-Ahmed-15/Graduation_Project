import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(IconData icon, String text, BuildContext context,
      Function onTapFunction) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(44, 62, 80, 1),
        ),
      ),
      onTap: onTapFunction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Color.fromRGBO(44, 62, 80, 1),
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
            Navigator.of(context).pushReplacementNamed('/parkingSlotsScreen');
          }),

          //>>
          buildListTile(Icons.settings, 'Settings', context, () {
            Navigator.of(context).pushReplacementNamed('/userProfileScreen');
          }),

          //>>
          buildListTile(Icons.help_outline, 'Get help', context, () {}),

          //>>
          buildListTile(Icons.info_outline, 'About app', context, () {}),

          //>>
          buildListTile(Icons.exit_to_app, 'Signout', context, () {
            Navigator.of(context).pop(context);
            Provider.of<AuthProvider>(context, listen: false).SignOut();
          }),
        ],
      ),
    );
  }
}
