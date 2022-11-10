import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/mapScreen.dart';
import 'package:graduation_project/global_variables.dart';
import 'package:graduation_project/models/UserInfo.dart';
import 'package:graduation_project/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String userKey;
  String userEmail;
  String userPassword;
  Timer logOutTimer;

  void notifyListnersToSwitchToMapScreen() {
    notifyListeners();
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Checking Authentication Function
  bool checkauthentication() {
    if (token != null) {
      return true;
    }
    return false;
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for getting the TOKEN,i may need the token from  somewhere else
  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) {
      return _token;
    }
    return null;
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Function for getting the user_id,i may need the token from  somewhere else

  String get getUserID {
    return _userId;
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// Signin/Signup User
  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$mapKey';

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      userEmail = email;
      userPassword = password;

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];

      currentUserId = _userId;
      authToken = _token;

      _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(responseData[
              'expiresIn']))); //must be calculated because the only thing we get back  is expiresIn which only contains a string but in that string we have the number the seconds So we'll have to parse that string and turn it into a number but then after turning it into a number, we have to derive a date from that. So expiry date should be a datetime object so we take the dateTime of now and add to it the amount of seconds that will expire in to generate a future date the token will expire in it

      final prefs = await SharedPreferences
          .getInstance(); //Now this here actually returns a future which eventually will return a shared preferences instance and that is then basically your tunnel to that on device storage. So we should await that so that we don't store the future in here but the real access to shared preferences and now we can use prefs to write and read data to and from the shared preferences device storage

      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      //Now we can store user data here and give that a key by which we can retrieve it and that key is totally up to you, should be a string and I'll just name it user data
      prefs.setString('userData', userData); //this to write data

      print(responseData);
    } catch (error) {
      rethrow;
    }

    await fetchCurrentUserOnline();

    if (urlSegment == 'signInWithPassword') {
      Navigator.pushNamedAndRemoveUntil(
          signInContext, MapScreen.routeName, (route) => false);
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  // Add user to firebase realtime database

  Future<void> addUserDataToRealTimeDataBase(
      String name, String address, String phoneNumber) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId.json?auth=$_token';

    try {
      var response = await http.post(Uri.parse(url),
          body: json.encode({
            'name': name,
            'id': _userId,
            'email': userEmail,
            'phoneNumber': phoneNumber,
            //'password': userPassword,
            'address': address,
            'penalty': 0,
            'wrongUse': 0,
            'nextBookFree': false,
            'crossedLimit': false,
            'rating': 'empty'
          }));

      final responseDecoded =
          json.decode(response.body) as Map<String, dynamic>;
      userKey = responseDecoded['name'];
    } catch (error) {
      rethrow;
    }

    await fetchCurrentUserOnline();
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<void> fetchCurrentUserOnline() async {
    try {
      print('Fetching User');
      String url =
          'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId.json?auth=$_token';

      var response = await http.get(Uri.parse(url));
      print('Fetching User yany');

      var singleUserDataRespone =
          await json.decode(response.body) as Map<String, dynamic>;

      if (singleUserDataRespone == null) {
        return;
      }
      print('Fetching User talt');
      userKey = singleUserDataRespone.keys.first.toString();

      UserInfo currentSingleUserInfo = UserInfo();
      currentSingleUserInfo.name = singleUserDataRespone.values.first['name'];
      currentSingleUserInfo.email = singleUserDataRespone.values.first['email'];
      currentSingleUserInfo.address =
          singleUserDataRespone.values.first['address'];
      currentSingleUserInfo.id = singleUserDataRespone.values.first['id'];
      currentSingleUserInfo.penalty =
          singleUserDataRespone.values.first['penalty'];
      currentSingleUserInfo.wrongUse =
          singleUserDataRespone.values.first['wrongUse'];
      currentSingleUserInfo.crossedLimit =
          singleUserDataRespone.values.first['crossedLimit'];

      currentSingleUserInfo.phoneNumber =
          singleUserDataRespone.values.first['phoneNumber'];
      currentSingleUserInfo.nextBookFree =
          singleUserDataRespone.values.first['nextBookFree'];
      currentSingleUserInfo.rating =
          singleUserDataRespone.values.first['rating'];

      currentUserOnline =
          currentSingleUserInfo; //dee el mafrood haga zayada ana bs bagarb lw a assign el value la global variable

      final prefs = await SharedPreferences.getInstance();

      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userKey': userKey,
        'nextBookFree': currentSingleUserInfo.nextBookFree,
        'wrongUse': currentSingleUserInfo.wrongUse,
        'crossedLimit': currentSingleUserInfo.crossedLimit,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      await prefs.setString('userData', userData);

      print('Fetched User');

      print('CURRENT USER DATA id:::===>>>   ${currentUserOnline.id}');
      print(
          'CURRENT USER DATA address :::===>>>   ${currentUserOnline.address}');
      print(
          'CURRENT USER DATA crossed limit :::===>>>   ${currentUserOnline.crossedLimit}');
      print('CURRENT USER DATA email:::===>>>   ${currentUserOnline.email}');
      print('CURRENT USER DATA name:::===>>>   ${currentUserOnline.name}');
      print(
          'CURRENT USER DATA nextBookFree:::===>>>   ${currentUserOnline.nextBookFree}');
      print(
          'CURRENT USER DATA penalty:::===>>>   ${currentUserOnline.penalty}');
      print(
          'CURRENT USER DATA phoneNumber:::===>>>   ${currentUserOnline.phoneNumber}');
      print('CURRENT USER DATA rating:::===>>>   ${currentUserOnline.rating}');
      print(
          'CURRENT USER DATA wrongUse:::===>>>   ${currentUserOnline.wrongUse}');
      print(
          'CURRENT USER DATA:::===>>> /////////////////////////////////////////////////////// AUTH PROVIDER');

      //notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<void> updateUserData(String name, String address, String phone) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId/$userKey.json?auth=$_token';

    try {
      await http.patch(
          Uri.parse(
              url), //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({
            'name': name,
            'address': address,
            'phoneNumber': phone,
          }));

      fetchCurrentUserOnline();
    } on SocketException {
      throw const SocketException('Internet Error');
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//User Signup
  Future<void> signUp(
    String email,
    String password,
  ) async {
    return _authenticate(
      email,
      password,
      'signUp',
    );
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//User signin
  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Auto Sigin
  Future<bool> tryAutoSignIn() async {
    print('Entered Auto sigin');
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];

    currentUserId = _userId;
    authToken = _token;
    _expiryDate = expiryDate;
    _autoSignOut();
    await fetchCurrentUserOnline();
    print('here');
    notifyListeners();

    return true;
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Signout Function
  Future<void> SignOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;

    currentUserId = null;
    authToken = null;

    if (logOutTimer != null) {
      logOutTimer.cancel();
      logOutTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();

    // final userData = json.encode({
    //   'token': null,
    //   'userId': null,
    //   'expiryDate': null,
    // });

    // prefs.setString('userData', userData);
    prefs.remove('userData');
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  void _autoSignOut() {
    if (logOutTimer != null) {
      logOutTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    logOutTimer = Timer(Duration(seconds: timeToExpiry), SignOut);
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

}
