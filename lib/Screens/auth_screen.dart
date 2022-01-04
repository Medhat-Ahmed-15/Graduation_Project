import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/auth_card.dart';
import 'package:graduation_project/widgets/main_drawer.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
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
          //The scrollable conntainer that is in it the auth card widget
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
