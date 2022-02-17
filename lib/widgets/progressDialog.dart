// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({this.message});

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      backgroundColor: colorProviderObj.genralBackgroundColor,
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorProviderObj.genralBackgroundColor,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(
                width: 6.0,
              ),
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 26.0,
              ),
              Text(
                message,
                style: TextStyle(
                    color: colorProviderObj.textColor, fontSize: 10.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
