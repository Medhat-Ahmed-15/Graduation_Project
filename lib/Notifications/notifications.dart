import 'package:awesome_notifications/awesome_notifications.dart';

class Notifications {
  //App is under  Maintenance Notification**************************************************************************
  static Future<void> createUserMissedHisSlotNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(
            100000), //If you want to be able to display multiple instances of a specific notification, then you must provide a unique id.
        channelKey: 'User_Missed_Parking_Slot',
        title: 'Hey there,',
        body:
            'Our system detected that your reserved parking slot has ended without any presence of a car',
        bigPicture: 'asset://assets/images/alert.png',
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }
}
