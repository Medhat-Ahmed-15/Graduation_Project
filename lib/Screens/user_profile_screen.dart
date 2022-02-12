import 'package:flutter/material.dart';
import 'package:graduation_project/providers/auth_provider.dart';
import 'package:graduation_project/providers/parking_slots_provider.dart';
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

  void _submitData() {}

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    Widget text(String text) {
      return Text(text,
          style: TextStyle(
              fontSize: 25,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700));
    }

    final authProviderObj = Provider.of<AuthProvider>(context);
    final userData =
        authProviderObj.findSingleUserById(authProviderObj.getUserID);
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Settings'),
    );

    userData == null
        ? _userNameController.text = ''
        : _userNameController.text = userData.first_name;

    return Scaffold(
      appBar: appBar,
      drawer: MainDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                  Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                stops: const [0, 1],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(50),
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Profile Settings',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: const [
                                  CircleAvatar(
                                    radius: 30.0,
                                    // backgroundImage: NetworkImage(null),
                                    backgroundImage:
                                        AssetImage('assets/images/person.png'),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Edit')
                                ],
                              ),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'First Name'),
                                  //                onChanged: (inputValue) {
                                  //   titleInput = inputValue;
                                  // },

                                  controller: _userNameController,
                                  onSubmitted: (_) => _submitData(),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
