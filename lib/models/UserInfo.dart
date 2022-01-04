// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/foundation.dart';

class UserInfo {
  String first_name;
  String last_name;
  String id;
  String email;
  String password;
  String address;
  String card_holder;
  String security_code;
  String credit_card_number;
  String expiration_date;

  UserInfo(
      {@required this.first_name,
      @required this.last_name,
      @required this.id,
      @required this.email,
      @required this.password,
      @required this.address,
      @required this.card_holder,
      @required this.security_code,
      @required this.credit_card_number,
      @required this.expiration_date});
}
