// ignore_for_file: non_constant_identifier_names, file_names


class UserInfo {
  String name;
  String id;
  String email;
  String address;
  String phoneNumber;
  int penalty;
  int wrongUse;
  String rating;
  bool nextBookFree;
  bool crossedLimit;

  UserInfo(
      {this.name,
      this.id,
      this.email,
      this.address,
      this.penalty,
      this.rating,
      this.phoneNumber,
      this.nextBookFree,
      this.wrongUse,
      this.crossedLimit});
}
