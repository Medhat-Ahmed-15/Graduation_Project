// ignore_for_file: file_names, missing_return

import 'package:flutter/material.dart';
import 'package:graduation_project/models/placePridictions.dart';

class PredictionTile extends StatelessWidget {
  PlacePredictions placePredictions;

  PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Row(
            children: [
              Icon(
                Icons.add_location,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 14.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      placePredictions.main_text,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      placePredictions.secondary_text,
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
    ));
  }
}
