class ParkingSlotBlueprint {
  String id;
  bool vip;
  bool sensorDetect;
  double latitude;
  double longitude;
  int gateOpen;
  Map<String, dynamic> reservationDates;
  bool parkedCorrectly;

  ParkingSlotBlueprint({
    this.id,
    this.latitude,
    this.longitude,
    this.vip,
    this.gateOpen,
    this.reservationDates,
    this.parkedCorrectly,
    this.sensorDetect,
  });
}
