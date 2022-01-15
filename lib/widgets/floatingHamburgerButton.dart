// ignore_for_file: file_names

import 'package:flutter/material.dart';

class FloatingHamburgerButton extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  FloatingHamburgerButton(this.scaffoldKey);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 45.0,
      left: 22.0,
      child: GestureDetector(
        onTap: () {
          scaffoldKey.currentState.openDrawer();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
            child: Icon(
              Icons.menu,
              color: Theme.of(context).primaryColor,
            ),
            radius: 20.0,
          ),
        ),
      ),
    );
  }
}
