// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationApi {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {

//     // Request permission to send notifications
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {

//       // Get FCMToken
//       final FCMToken = await _firebaseMessaging.getToken();
//     } else {
//     }
//   }
// }
