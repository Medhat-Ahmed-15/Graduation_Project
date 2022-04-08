// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Assistants/assistant_function.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/providers/color_provider.dart';

import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class VerificationDialog extends StatefulWidget {
  Function ConfirmArrival;

  VerificationDialog(this.ConfirmArrival);

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  bool wrongCode;

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: colorProviderObj.generalCardColor,
      elevation: 1.0,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: colorProviderObj.genralBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: OTPTextField(
          length: 4,
          textFieldAlignment: MainAxisAlignment.spaceAround,
          fieldWidth: 50,
          fieldStyle: FieldStyle.box,
          outlineBorderRadius: 15,
          style: TextStyle(fontSize: 17, color: colorProviderObj.textColor),
          onCompleted: (pin) async {
            final verificationCode = await getVerificationCodeFromStorage();

            print('code: ' + " " + verificationCode);

            if (pin == verificationCode) {
              Navigator.pop(context);
              widget.ConfirmArrival(colorProviderObj);
            } else {
              Fluttertoast.showToast(
                  msg: 'Invalid code ❗',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 5,
                  backgroundColor: colorProviderObj.genralBackgroundColor,
                  textColor: colorProviderObj.textColor,
                  fontSize: 16.0);
            }
          },
        ),
      ),
    );
  }
}
