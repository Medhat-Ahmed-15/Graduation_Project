import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/models/http_exception.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  static const routeName = '/CompleteProfileScreen';
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  ColorProvider colorProviderObj;

  bool _isInit = true;
  bool loading = false;
  bool showErrorText = false;

  Color nameBorderColor;
  Color nameFillColor;
  Color nameIconColor;
  Color nameInputTextColor;

  Color addressBorderColor;
  Color addressFillColor;
  Color addressIconColor;
  Color addressInputTextColor;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String errortext;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

      nameBorderColor = colorProviderObj.genralBackgroundColor;
      nameFillColor = colorProviderObj.genralBackgroundColor;
      nameIconColor = Colors.grey[600];
      nameInputTextColor = colorProviderObj.textColor;

      addressBorderColor = colorProviderObj.genralBackgroundColor;
      addressFillColor = colorProviderObj.genralBackgroundColor;
      addressIconColor = Colors.grey[600];
      addressInputTextColor = colorProviderObj.textColor;
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

  Future<void> addingUserDataToRealTimeDataBase() async {
    if (_nameController.text == "" && _addressController.text == "") {
      setState(() {
        nameBorderColor = Colors.red;
        nameIconColor = Colors.red;
        nameInputTextColor = Colors.red;

        addressBorderColor = Colors.red;
        addressIconColor = Colors.red;
        addressInputTextColor = Colors.red;

        showErrorText = true;

        errortext = "Empty fields ❗";
      });

      return;
    }
    if (_addressController.text == "") {
      setState(() {
        addressBorderColor = Colors.red;
        addressIconColor = Colors.red;
        addressInputTextColor = Colors.red;

        showErrorText = true;

        errortext = "Empty field ❗";
      });

      return;
    }
    if (_nameController.text == "") {
      setState(() {
        nameBorderColor = Colors.red;
        nameIconColor = Colors.red;
        nameInputTextColor = Colors.red;

        showErrorText = true;

        errortext = "Empty fields ❗";
      });

      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await Provider.of<AuthProvider>(context, listen: false)
          .addUserDataToRealTimeDataBase(
              _nameController.text.trim(),
              _addressController.text.trim(),
              'card_holder',
              'security_code',
              'credit_card_number',
              'expiration_date');

      Navigator.pushReplacementNamed(context, MapScreen.routeName);
    } catch (error) {
      showErrorDialog(error);

      return;
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
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: Main,
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                'Complete your profile',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: colorProviderObj.textColor),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'We are almost done...let\'s go🚀',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.grey[600]),
              ),

              const SizedBox(
                height: 50,
              ),

              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 100,
                child: CircleAvatar(
                    radius: 98,
                    backgroundColor: colorProviderObj.generalCardColor,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 100,
                    )),
              ),

              //Name textfield************************************************************************************

              Container(
                margin: EdgeInsets.only(top: 50, left: 25, right: 30),
                decoration: BoxDecoration(
                  color: nameFillColor,
                  border: Border.all(
                    color: nameBorderColor,
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
                      Icons.person_outline_outlined,
                      color: nameIconColor,
                    ),
                    Container(
                      width: 300,
                      child: TextField(
                        onTap: () {
                          setState(() {
                            nameInputTextColor = colorProviderObj.textColor;
                            nameFillColor = colorProviderObj.generalCardColor;
                            nameBorderColor = Theme.of(context).primaryColor;
                            nameIconColor = Theme.of(context).primaryColor;
                          });
                        },
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        cursorColor: Theme.of(context).primaryColor,
                        style: TextStyle(
                          color: nameInputTextColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8),
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //address textfield************************************************************************************

              Container(
                margin: EdgeInsets.only(top: 35, left: 25, right: 30),
                decoration: BoxDecoration(
                  color: addressFillColor,
                  border: Border.all(
                    color: addressBorderColor,
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
                      Icons.home_outlined,
                      color: addressIconColor,
                    ),
                    Container(
                      width: 300,
                      child: TextField(
                        onTap: () {
                          setState(() {
                            addressInputTextColor = colorProviderObj.textColor;
                            addressFillColor =
                                colorProviderObj.generalCardColor;
                            addressBorderColor = Theme.of(context).primaryColor;
                            addressIconColor = Theme.of(context).primaryColor;
                          });
                        },
                        controller: _addressController,
                        keyboardType: TextInputType.text,
                        cursorColor: Theme.of(context).primaryColor,
                        style: TextStyle(
                          color: addressInputTextColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8),
                          hintText: 'Address',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
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
                        '$errortext',
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
                            'Sign up',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                onPressed: () {
                  addingUserDataToRealTimeDataBase();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
