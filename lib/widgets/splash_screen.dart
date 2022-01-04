import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
