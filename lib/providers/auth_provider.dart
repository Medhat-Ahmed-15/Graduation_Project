import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  UserInfo singleUserInfo;

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
      final response = await http.post(url,
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
      throw error;
    }

    fetchCurrentUserOnline();
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  // Add user to firebase realtime database

  Future<void> addUserDataToRealTimeDataBase(
      String name,
      String address,
      String card_holder,
      String security_code,
      String credit_card_number,
      String expiration_date) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId.json?auth=$_token';

    try {
      var response = await http.post(url,
          body: json.encode({
            'name': name,
            'id': _userId,
            'email': userEmail,
            'password': userPassword,
            'address': address,
            'card_holder': card_holder,
            'security_code': security_code,
            'credit_card_number': credit_card_number,
            'expiration_date': expiration_date,
          }));
    } catch (error) {
      throw error;
    }

    fetchCurrentUserOnline();
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<void> fetchCurrentUserOnline() async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId.json?auth=$_token';

    try {
      var response = await http.get(url);

      var singleUserDataRespone =
          json.decode(response.body) as Map<String, dynamic>;

      if (singleUserDataRespone == null) {
        return;
      }

      userKey = singleUserDataRespone.keys.first.toString();

      UserInfo currentSingleUserInfo = new UserInfo();
      currentSingleUserInfo.name = singleUserDataRespone.values.first['name'];

      currentSingleUserInfo.email = singleUserDataRespone.values.first['email'];

      currentSingleUserInfo.password =
          singleUserDataRespone.values.first['password'];

      currentSingleUserInfo.address =
          singleUserDataRespone.values.first['address'];

      currentSingleUserInfo.id = singleUserDataRespone.values.first['id'];

      singleUserInfo = currentSingleUserInfo;
      currentUserOnline =
          currentSingleUserInfo; //dee el mafrood haga zayada ana bs bagarb lw a assign el value la global variable

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Future<void> updateUserData(UserInfo updatedUserData) async {
    String url =
        'https://rakane-13d27-default-rtdb.firebaseio.com/Users/$_userId/$userKey.json?auth=$_token';

    try {
      await http.put(
          url, //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
          body: json.encode({
            'name': updatedUserData.name,
            'id': updatedUserData.id,
            'email': updatedUserData.email,
            'password': updatedUserData.password,
            'address': updatedUserData.address,
            'card_holder': updatedUserData.card_holder,
            'security_code': updatedUserData.security_code,
            'credit_card_number': updatedUserData.credit_card_number,
            'expiration_date': updatedUserData.expiration_date,
          }));

      notifyListeners();
      fetchCurrentUserOnline();
    } catch (error) {
      throw error;
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
    notifyListeners();
    _autoSignOut();
    fetchCurrentUserOnline();
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
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    final userData = json.encode({
      'token': null,
      'userId': null,
      'expiryDate': null,
    });

    prefs.setString('userData', userData);
    // prefs.clear();
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
