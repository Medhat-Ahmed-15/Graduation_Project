import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/complete_profile_screen.dart';
import 'package:graduation_project/models/http_exception.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/SignupScreen';
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  ColorProvider colorProviderObj;

  bool _isInit = true;
  bool loading = false;
  bool showErrorText = false;
  bool hidePasswordText = true;
  bool hideConfirmPasswordText = true;

  Color emailBorderColor;
  Color emailFillColor;
  Color emailIconColor;
  Color emailInputTextColor;

  Color passwordBorderColor;
  Color passwordFillColor;
  Color passwordIconColor;
  Color passwordInputTextColor;
  Color passwordEyeColor;

  Color confirmPasswordBorderColor;
  Color confirmPasswordFillColor;
  Color confirmPasswordIconColor;
  Color confirmPasswordInputTextColor;
  Color confirmPasswordEyeColor;

  final _emailAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String errortext;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

      emailBorderColor = colorProviderObj.genralBackgroundColor;
      emailFillColor = colorProviderObj.genralBackgroundColor;
      emailIconColor = Colors.grey[600];
      emailInputTextColor = colorProviderObj.textColor;

      passwordBorderColor = colorProviderObj.genralBackgroundColor;
      passwordFillColor = colorProviderObj.genralBackgroundColor;
      passwordIconColor = Colors.grey[600];
      passwordInputTextColor = colorProviderObj.textColor;
      passwordEyeColor = Colors.grey[600];

      confirmPasswordBorderColor = colorProviderObj.genralBackgroundColor;
      confirmPasswordFillColor = colorProviderObj.genralBackgroundColor;
      confirmPasswordIconColor = Colors.grey[600];
      confirmPasswordInputTextColor = colorProviderObj.textColor;
      confirmPasswordEyeColor = Colors.grey[600];
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> checkThemeMode(BuildContext context) async {
    await Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      barrierColor: Colors.white10,
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Provider.of<ColorProvider>(context, listen: true)
            .genralBackgroundColor,
        title: const Text('An Error Occurred!'),
        titleTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        content: Text(
          errorMessage,
          style: TextStyle(
              color:
                  Provider.of<ColorProvider>(context, listen: true).textColor),
        ),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay',
                  style: TextStyle(color: Theme.of(context).primaryColor)))
        ],
      ),
    );
  }

  Future<void> signUpUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        passwordBorderColor = Colors.red;
        passwordIconColor = Colors.red;
        passwordInputTextColor = Colors.red;
        passwordEyeColor = Colors.red;

        confirmPasswordEyeColor = Colors.red;
        confirmPasswordBorderColor = Colors.red;
        confirmPasswordIconColor = Colors.red;
        confirmPasswordInputTextColor = Colors.red;

        showErrorText = true;

        errortext = "Passwords don't match";
      });

      return;
    }

    try {
      setState(() {
        loading = true;
      });
      await Provider.of<AuthProvider>(context, listen: false).signUp(
          _emailAddressController.text.trim(), _passwordController.text.trim());
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      }

      if (errorMessage == 'This password is too weak.') {
        setState(() {
          passwordBorderColor = Colors.red;
          passwordIconColor = Colors.red;
          passwordInputTextColor = Colors.red;
          passwordEyeColor = Colors.red;

          confirmPasswordEyeColor = Colors.red;
          confirmPasswordBorderColor = Colors.red;
          confirmPasswordIconColor = Colors.red;
          confirmPasswordInputTextColor = Colors.red;

          showErrorText = true;
          errortext = errorMessage;
        });
      } else if (errorMessage == 'This email address is already in use.' ||
          errorMessage == 'This is not a valid email address') {
        setState(() {
          emailBorderColor = Colors.red;
          emailIconColor = Colors.red;
          emailInputTextColor = Colors.red;
          showErrorText = true;
          errortext = errorMessage;
        });
      } else {
        showErrorDialog(errorMessage);
      }

      setState(() {
        loading = false;
      });

      return;
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage);

      setState(() {
        loading = false;
      });

      return;
    }
    setState(() {
      loading = false;
    });

    Navigator.pushReplacementNamed(context, CompleteProfileScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    checkThemeMode(context);
    return Scaffold(
      backgroundColor: colorProviderObj.generalCardColor,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: Main,
          children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              'Welcome 👋',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: colorProviderObj.textColor),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'I am happy to see you here ❤',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Colors.grey[600]),
            ),

            //Email signin textfield************************************************************************************

            Container(
              margin: EdgeInsets.only(top: 50, left: 25, right: 30),
              decoration: BoxDecoration(
                color: emailFillColor,
                border: Border.all(
                  color: emailBorderColor,
                  width: 1.5,
                ),
                // color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              // width: 400,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: emailIconColor,
                  ),
                  Container(
                    width: 300,
                    child: TextField(
                      onTap: () {
                        emailInputTextColor = colorProviderObj.textColor;
                        emailFillColor = colorProviderObj.generalCardColor;
                        emailBorderColor = Theme.of(context).primaryColor;
                        emailIconColor = Theme.of(context).primaryColor;
                      },
                      controller: _emailAddressController,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                        color: emailInputTextColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(8),
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            //password signin textfield************************************************************************************

            Container(
              margin: EdgeInsets.only(top: 35, left: 25, right: 30),
              decoration: BoxDecoration(
                color: passwordFillColor,
                border: Border.all(
                  color: passwordBorderColor,
                  width: 1.5,
                ),
                // color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: passwordIconColor,
                  ),
                  Container(
                    width: 270,
                    child: TextField(
                      onTap: () {
                        passwordInputTextColor = colorProviderObj.textColor;
                        passwordFillColor = colorProviderObj.generalCardColor;
                        passwordBorderColor = Theme.of(context).primaryColor;
                        passwordIconColor = Theme.of(context).primaryColor;
                      },
                      controller: _passwordController,
                      obscureText: hidePasswordText,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                        color: passwordInputTextColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(8),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          bool prevHidePasswordText = hidePasswordText;
                          hidePasswordText = !prevHidePasswordText;
                        });
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: passwordIconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //confirm password signin textfield************************************************************************************

            Container(
              margin: EdgeInsets.only(top: 35, left: 25, right: 30),
              decoration: BoxDecoration(
                color: confirmPasswordFillColor,
                border: Border.all(
                  color: confirmPasswordBorderColor,
                  width: 1.5,
                ),
                // color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: confirmPasswordIconColor,
                  ),
                  Container(
                    width: 270,
                    child: TextField(
                      onTap: () {
                        confirmPasswordInputTextColor =
                            colorProviderObj.textColor;
                        confirmPasswordFillColor =
                            colorProviderObj.generalCardColor;
                        confirmPasswordBorderColor =
                            Theme.of(context).primaryColor;
                        confirmPasswordIconColor =
                            Theme.of(context).primaryColor;
                      },
                      controller: _confirmPasswordController,
                      obscureText: hideConfirmPasswordText,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                        color: confirmPasswordInputTextColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(8),
                        hintText: 'Confirm password',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          bool prevHideConfirmPasswordText =
                              hideConfirmPasswordText;
                          hideConfirmPasswordText =
                              !prevHideConfirmPasswordText;
                        });
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: confirmPasswordIconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //error text
            showErrorText == true
                ? Container(
                    margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                    child: Text(
                      '❗$errortext',
                      style: const TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  )
                : SizedBox(height: 0),

            FlatButton(
              child: Container(
                margin: EdgeInsets.only(top: 100, left: 20, right: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                  color: colorProviderObj.generalCardColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 60,
                width: 400,
                child: loading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(8),
                        child: Image.asset('assets/images/right_arrow.png'),
                      ),
              ),
              onPressed: () {
                signUpUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}
