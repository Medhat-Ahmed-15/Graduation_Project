// ignore_for_file: file_names
class RequestedParkingSlotDetailsBluePrint {
  String userId;
  String paymentMethod;
  String parkingAreaAddressName;
  String parkingSlotId;
  int totalCost;
  String startDateTime;
  String endDateTime;
  Map destinationLocMap;
  String status;

  RequestedParkingSlotDetailsBluePrint({
    this.userId,
    this.paymentMethod,
    this.destinationLocMap,
    this.status,
    this.endDateTime,
    this.parkingAreaAddressName,
    this.parkingSlotId,
    this.startDateTime,
    this.totalCost,
  });
}
