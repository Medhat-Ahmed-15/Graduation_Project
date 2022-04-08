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
  String latitude;
  String longitude;
  String status;

  RequestedParkingSlotDetailsBluePrint({
    this.requestId,
    this.userId,
    this.paymentMethod,
    this.latitude,
    this.longitude,
    this.status,
    this.endDateTime,
    this.parkingAreaAddressName,
    this.parkingSlotId,
    this.startDateTime,
    this.totalCost,
  });
}
