import 'package:flutter/material.dart';
import 'package:graduation_project/models/UserInfo.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:graduation_project/providers/color_provider.dart';
import 'package:graduation_project/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

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

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });
      Provider.of<AuthProvider>(context).fetchUsers().then((_) => setState(() {
            _loadingSpinner = false;
          }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
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
        singleUserData == null
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Container(
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

  void updateUserData(
      UserInfo singleUserData, AuthProvider authProviderObj) async {
    String updatedAddress = addressController.text == ""
        ? singleUserData.address
        : addressController.text;
    UserInfo updatedCurrentUserData = new UserInfo();
    updatedCurrentUserData.first_name = singleUserData.first_name;
    updatedCurrentUserData.last_name = singleUserData.last_name;
    updatedCurrentUserData.id = singleUserData.id;
    updatedCurrentUserData.email = singleUserData.email;
    updatedCurrentUserData.password = singleUserData.password;
    updatedCurrentUserData.address = updatedAddress;
    updatedCurrentUserData.card_holder = singleUserData.card_holder;
    updatedCurrentUserData.credit_card_number =
        singleUserData.credit_card_number;
    updatedCurrentUserData.expiration_date = singleUserData.expiration_date;
    updatedCurrentUserData.security_code = singleUserData.security_code;

    setState(() {
      _saveLoadinfSpinner = true;
    });

    await authProviderObj.updateUserData(updatedCurrentUserData);

    setState(() {
      _saveLoadinfSpinner = false;
    });
  }

  void checkThemeMode(BuildContext context) {
    Provider.of<ColorProvider>(context, listen: false)
        .checkThemeMethodInThisScreen();
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Provider.of<ColorProvider>(context, listen: true);

    final singleUserData = Provider.of<AuthProvider>(context).singleUserInfo;
    final authProviderObj = Provider.of<AuthProvider>(context);

    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Profile'),
      actions: [
        _saveLoadinfSpinner == true
            ? Container(
                margin: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  color: const Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                ),
              )
            : IconButton(
                onPressed: () {
                  updateUserData(singleUserData, authProviderObj);
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
                            height: 45,
                          ),
                          CircleAvatar(
                            backgroundColor: colorProviderObj.generalCardColor,
                            radius: 50,
                            child: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 40,
                              backgroundImage: AssetImage(
                                'assets/images/person.png',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Edit',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor),
                          ),
                          const Expanded(
                            child: Text(''),
                          ),
                          singleUserData == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : Text(
                                  '${singleUserData.first_name} ${singleUserData.last_name}',
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
                            singleUserData, 'id', 'assets/images/id.png'),
                        const SizedBox(
                          height: 15,
                        ),
                        buildNonEditableFields(
                            singleUserData, 'email', 'assets/images/email.png'),
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
                        buildEditableFieldsContainer(singleUserData,
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
