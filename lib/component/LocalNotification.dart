
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spam2/api/FirebaseApi.dart';

class LocalNotification {

  static final LocalNotification _instance = LocalNotification._internal();
  factory LocalNotification() => _instance;
  LocalNotification._internal();

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for notification',
    // importance: Importance.defaultImportance,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  init() async {
    await _permissionWithNotification();

    InitializationSettings settings = const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    );

    await _local.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 처리
        print('알림 클릭: ${response.payload}');
      },
    );

    final platform = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    platform?.requestNotificationsPermission();
    await platform?.createNotificationChannel(_androidChannel);
  }

  _permissionWithNotification() async {
    print('permission : ${await Permission.notification.isGranted}');
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  show(FcmMessage message) async {
    _local.show(
        message.hashCode,
        message.title,
        message.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
            channelDescription:  _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        payload: jsonEncode(message.toMap()),
    );
  }

}