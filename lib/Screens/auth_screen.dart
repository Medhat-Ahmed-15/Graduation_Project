import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/auth_card.dart';
import 'package:graduation_project/widgets/main_drawer.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          //Container that is responsible for the background color
          Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
              //     Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.topRight,
              //   stops: [0, 1],
              // ),
              color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: isKeyboard ? 150 : 300,
              height: isKeyboard ? 150 : 300,
              margin: EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/parking.png"),
                ),
              ),
            ),
          ),
          AuthCard()
        ],
      ),
    );
  }
}
