// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Divider(
      height: 1.0,
      color: colorProviderObj.textColor,
      thickness: 1.0,
    );
  }
}
