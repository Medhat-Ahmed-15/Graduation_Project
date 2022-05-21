import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/UserInfo.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
//import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/userProfileScreen';
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var _isInit = true;
  final _userNameController = TextEditingController();
  final _userEmailSettings = TextEditingController();
  bool _loadingSpinner = true;
  bool _saveLoadinfSpinner = false;
  final addressController = TextEditingController();
  File _pickedImage;

  Widget buildNonEditableFields(
      UserInfo singleUserData, String flag, String umlImage) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: ExactAssetImage(umlImage),
            fit: BoxFit.fitHeight,
          )),
        ),
        const SizedBox(
          width: 10,
        ),
        singleUserData == null
            ? Center(
                child: LinearProgressIndicator(
                color: Theme.of(context).primaryColor,
              ))
            : Text(
                flag == 'id' ? singleUserData.id : singleUserData.email,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Theme.of(context).primaryColor),
              ),
      ],
    );
  }
//build Editable Fields Container*********************************************************

  Widget buildEditableFieldsContainer(UserInfo singleUserData,
      ColorProvider colorProviderObj, String umlImage) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: ExactAssetImage(umlImage),
            fit: BoxFit.fitHeight,
          )),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          width: 200,
          child: TextField(
            controller: addressController,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(
              color: colorProviderObj.textColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                  left: 15, bottom: 11, top: 11, right: 15),
              hintText: singleUserData.address,
              hintStyle: TextStyle(
                color: colorProviderObj.textColor,
              ),
            ),
          ),
        )
      ],
    );
  }
//update User Data Method*********************************************************

  void updateUserData(AuthProvider authProviderObj) async {
    var userId = Provider.of<AuthProvider>(context, listen: false).getUserID;

    String updatedAddress = addressController.text == ""
        ? currentUserOnline.address
        : addressController.text;
    UserInfo updatedCurrentUserData = new UserInfo();
    updatedCurrentUserData.name = currentUserOnline.name;
    updatedCurrentUserData.id = currentUserOnline.id;
    updatedCurrentUserData.email = currentUserOnline.email;
    updatedCurrentUserData.address = updatedAddress;

    setState(() {
      _saveLoadinfSpinner = true;
    });

    await authProviderObj.updateUserData(updatedCurrentUserData);

    setState(() {
      _saveLoadinfSpinner = false;
    });
  }
//check Theme Mode*********************************************************

  void checkThemeMode(BuildContext context) {
    Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  //pick Image *********************************************************

  // void _pickImage() async {
  //   final pickedImagefile = await ImagePicker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality:
  //           50, //since 2n el  default size of the captured image is a littlt bit high so I made the quality  50
  //       maxWidth: 150 //to ensure that the image is small
  //       );
  //   setState(() {
  //     _pickedImage = pickedImagefile;
  //   });
  //   //widget._pickedImageFunction(pickedImagefile);
  // }

  //build*********************************************************

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    // final singleUserData = Provider.of<AuthProvider>(context).singleUserInfo;
    final authProviderObj = Provider.of<AuthProvider>(context);

    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Profile'),
      actions: [
        _saveLoadinfSpinner == true
            ? Container(
                margin: EdgeInsets.all(10),
                child: CircularProgressIndicator(color: Colors.white))
            : IconButton(
                onPressed: () {
                  updateUserData(authProviderObj);
                },
                icon: Icon(Icons.save))
      ],
    );

    return Scaffold(
      appBar: appBar,
      drawer: MainDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorProviderObj.generalCardColor,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                    height: 250.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorProviderObj.genralBackgroundColor,
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          CircleAvatar(
                            backgroundColor: colorProviderObj.generalCardColor,
                            radius: 50,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 40,
                              backgroundImage: _pickedImage != null
                                  ? FileImage(
                                      _pickedImage,
                                    )
                                  : const AssetImage(
                                      'assets/images/person.png',
                                    ),
                            ),
                          ),
                          FlatButton(
                            onPressed:
                                null, // _pickImage, //=================================================================================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          const Expanded(
                            child: Text(''),
                          ),
                          currentUserOnline == null
                              ? Center(
                                  child: LinearProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ))
                              : Text(
                                  currentUserOnline.name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: colorProviderObj.textColor),
                                ),
                          const SizedBox(
                            height: 30,
                          ),
                        ]),
                  ),
                ),

                //Build Non editable fields (email,id)********************************************
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorProviderObj.generalCardColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    // color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        buildNonEditableFields(
                            currentUserOnline, 'id', 'assets/images/id.png'),
                        const SizedBox(
                          height: 15,
                        ),
                        buildNonEditableFields(currentUserOnline, 'email',
                            'assets/images/email.png'),
                      ],
                    ),
                  ),
                ),

                //Build editable fields (address,id)********************************************

                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorProviderObj.generalCardColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    // color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        buildEditableFieldsContainer(currentUserOnline,
                            colorProviderObj, 'assets/images/address.png'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
