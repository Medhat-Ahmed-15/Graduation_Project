// ignore_for_file: file_names
class RequestedParkingSlotDetailsBluePrint {
  String requestId;
  String userId;
  String paymentMethod;
  String parkingAreaAddressName;
  String parkingSlotId;
  int totalCost;
  String startDateTime;
  String endDateTime;
  String slotLatitude;
  String slotLongitude;
  String status;
  String rate;
  bool vip;

  RequestedParkingSlotDetailsBluePrint(
      {this.requestId,
      this.userId,
      this.paymentMethod,
      this.slotLatitude,
      this.slotLongitude,
      this.status,
      this.rate,
      this.endDateTime,
      this.parkingAreaAddressName,
      this.parkingSlotId,
      this.startDateTime,
      this.totalCost,
      this.vip});
}
