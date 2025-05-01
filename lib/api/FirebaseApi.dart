
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:spam2/component/LocalNotification.dart';
import 'package:spam2/firebase_options.dart';

class FirebaseApi {

  static final FirebaseApi _instance = FirebaseApi._internal();
  factory FirebaseApi() => _instance;
  FirebaseApi._internal();

  //function to init notification
  Future<void> initNotifications() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initPushNotifications();
  }

  //function to handle received Msg
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print('mattabu: $message');
  }

  Future _initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Notification title : ${message.notification?.title}, body : ${message.notification?.body}');
      print('Message data: ${message.data}');
      // if (message.notification == null) return;
      //
      // final fcmMessage = FcmMessage.fromMap(message.data);
      //
      // print('제목 : ${fcmMessage.title}, 내용 : ${fcmMessage.body}');
      // print('Message also contained a notification: ${message.notification}');
      //
      // LocalNotification().show(fcmMessage);
    });
  }
}

class FcmMessage {

  final String name;
  final String title;
  final String body;

  FcmMessage({required this.name, required this.title, required this.body});

  FcmMessage.fromMap(Map<String, dynamic> map):
    name = map['name'],
    title = map['title'],
    body = map['body'];

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'title' : title,
      'body' : body
    };
  }

}