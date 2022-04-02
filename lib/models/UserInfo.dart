// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/foundation.dart';

class UserInfo {
  String name;
  String id;
  String email;
  String password;
  String address;
  String card_holder;
  String security_code;
  String credit_card_number;
  String expiration_date;

  UserInfo(
      {this.name,
      this.id,
      this.email,
      this.password,
      this.address,
      this.card_holder,
      this.security_code,
      this.credit_card_number,
      this.expiration_date});
}
