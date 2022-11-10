// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class SingleReservedTimeWidget extends StatefulWidget {
  DateTimeRange dateTimeRange;
  SingleReservedTimeWidget(this.dateTimeRange);

  @override
  State<SingleReservedTimeWidget> createState() =>
      _SingleReservedTimeWidgetState();
}

class _SingleReservedTimeWidgetState extends State<SingleReservedTimeWidget> {
  ColorProvider colorProviderObj;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
            spreadRadius: 2,
            offset: Offset(0.2, 0.2),
          ),
        ],
        color: colorProviderObj.generalCardColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/dateTime.png',
                  height: 24.0,
                  width: 24.0,
                ),
                Expanded(child: Container()),
                Text(
                  DateFormat.yMEd()
                      .add_jms()
                      .format(widget.dateTimeRange.start),
                  style: TextStyle(color: colorProviderObj.textColor),
                ),
                Expanded(child: Container()),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Image.asset(
                  'assets/images/dateTime.png',
                  height: 24.0,
                  width: 24.0,
                ),
                Expanded(child: Container()),
                Text(
                  DateFormat.yMEd().add_jms().format(widget.dateTimeRange.end),
                  style: TextStyle(color: colorProviderObj.textColor),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
