import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/signup_screen.dart';
import 'package:graduation_project/models/http_exception.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  static const routeName = '/SigninScreen';
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  ColorProvider colorProviderObj;

  bool _isInit = true;
  bool loading = false;
  bool showErrorText = false;
  bool hidePasswordText = true;

  Color emailBorderColor;
  Color emailFillColor;
  Color emailIconColor;
  Color emailInputTextColor;

  Color passwordBorderColor;
  Color passwordFillColor;
  Color passwordIconColor;
  Color passwordInputTextColor;
  Color eyeColor;

  final _emailAddressController = TextEditingController();
  final _passwordController = TextEditingController();

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
      eyeColor = Colors.grey[600];
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

//Sign in Function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<void> signInUser() async {
    print("data:" +
        "  " +
        _emailAddressController.text +
        _passwordController.text);
    try {
      setState(() {
        loading = true;
      });

      await Provider.of<AuthProvider>(context, listen: false).signIn(
        _emailAddressController.text.trim(),
        _passwordController.text.trim(),
      );

      Provider.of<AuthProvider>(context, listen: false)
          .notifyListnersToSwitchToMapScreen();
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      if (errorMessage == 'Invalid password.') {
        setState(() {
          passwordBorderColor = Colors.red;
          passwordIconColor = Colors.red;
          passwordInputTextColor = Colors.red;
          showErrorText = true;
          eyeColor = Colors.red;
          errortext = errorMessage;
        });
      } else if (errorMessage == 'Could not find a user with that email.' ||
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
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage);
    }
    setState(() {
      loading = false;
    });
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
            Container(
                //padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(top: 30, left: 0),
                height: 180,
                width: 180,
                child: Image.asset('assets/images/parking.png')),

            Text(
              'GoPark',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: colorProviderObj.textColor),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Sign in to continue',
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
                        setState(() {
                          emailInputTextColor = colorProviderObj.textColor;
                          emailFillColor = colorProviderObj.generalCardColor;
                          emailBorderColor = Theme.of(context).primaryColor;
                          emailIconColor = Theme.of(context).primaryColor;
                        });
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
              margin: EdgeInsets.only(top: 25, left: 25, right: 30),
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
                        setState(() {
                          passwordInputTextColor = colorProviderObj.textColor;
                          passwordFillColor = colorProviderObj.generalCardColor;
                          passwordBorderColor = Theme.of(context).primaryColor;
                          passwordIconColor = Theme.of(context).primaryColor;
                        });
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
                margin: EdgeInsets.only(top: 50, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 50,
                width: 400,
                child: Align(
                  alignment: Alignment.center,
                  child: loading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              onPressed: () {
                signInUser();
              },
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              '- OR -',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Colors.grey[600]),
            ),

            const SizedBox(
              height: 20,
            ),

            //Google Button****************************************************

            FlatButton(
              child: Container(
                margin: EdgeInsets.only(top: 0, left: 20, right: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                  color: colorProviderObj.generalCardColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 50,
                width: 400,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Image.asset('assets/images/google.png'),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Text(
                      'Sign in with google',
                      style: TextStyle(
                          color: colorProviderObj.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                //sign_in(context);
              },
            ),

            const SizedBox(
              height: 20,
            ),
            //Facebook Button****************************************************

            FlatButton(
              child: Container(
                margin: EdgeInsets.only(top: 0, left: 20, right: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                  color: colorProviderObj.generalCardColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: 50,
                width: 400,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Image.asset('assets/images/facebook.png'),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Text(
                      'Sign in with Facebook',
                      style: TextStyle(
                          color: colorProviderObj.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                //sign_in(context);
              },
            ),
            const SizedBox(
              height: 50,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Do you have an account?',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: Colors.grey[600]),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignupScreen.routeName);
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
