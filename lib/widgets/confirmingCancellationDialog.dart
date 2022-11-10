// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

class ConfirmingCancellationDialog extends StatefulWidget {
  Function cancelrequest;

  ConfirmingCancellationDialog(this.cancelrequest);

  @override
  State<ConfirmingCancellationDialog> createState() =>
      _ConfirmingCancellationDialogState();
}

class _ConfirmingCancellationDialogState
    extends State<ConfirmingCancellationDialog> {
  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: colorProviderObj.generalCardColor,
      elevation: 1.0,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorProviderObj.generalCardColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            Image.asset(
              'assets/images/sad.png',
              width: 120.0,
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Are you sure you want to cancel ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                    color: colorProviderObj.textColor),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        color: colorProviderObj.generalCardColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      //height: 90,
                      child: const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // height: 90,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: loading == true
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: colorProviderObj.textColor,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.cancelrequest();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
