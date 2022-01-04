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

  @override
  Widget build(BuildContext context) {
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
      title: const Text('User Settings'),
    );

    return Scaffold(
      appBar: appBar,
      drawer: MainDrawer(),
      body: Container(
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
          child: _loadingSpinner == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: text(userData.first_name),
                )),
    );
  }
}
