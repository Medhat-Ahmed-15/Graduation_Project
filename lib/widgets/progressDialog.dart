// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(
                width: 6.0,
              ),
              const CircularProgressIndicator(
                color: Colors.pink,
              ),
              const SizedBox(
                width: 26.0,
              ),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
