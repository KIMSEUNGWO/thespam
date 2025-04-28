import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spam2/api/ApiService.dart';
import 'package:spam2/api/FirebaseApi.dart';
import 'package:spam2/component/LocalNotification.dart';
import 'package:spam2/component/local_storage.dart';
import 'package:spam2/firebase_options.dart';
import 'package:spam2/setting/DeviceController.dart';
import 'package:spam2/widget/HomeWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await LocalNotification().init();
  await FirebaseApi().initNotifications();
  await LocalStorage().init();
  final apiService = ApiService();
  apiService.deviceLogin();

  DeviceHelper().init();
  runApp(const ProviderScope(
    child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '통화맑음',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeWidget(),
      theme: _themeData(),
    );
  }
}

_themeData() {
  return ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Color(0xFF2A2E43),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    ),
    colorScheme: const ColorScheme.light(

      onPrimary: Color(0xFF41BA45), // 메인 컬러 1

      primary: Color(0xFF2A2E43), // 폰트 컬러 1
      secondary: Color(0xFF45495E), // 폰트 컬러 2
      tertiary: Color(0xFF777984), // 폰트 컬러 3

      error: Color(0xFFE42323),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 26,
        color: Color(0xFF2A2E43),
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      displayMedium: TextStyle(
        fontSize: 21,
        color: Color(0xFF2A2E43),
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        color: Color(0xFF45495E),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF45495E),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF777984),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF777984),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 Firebase 초기화가 필요합니다
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("백그라운드 메시지 처리: ${message.messageId}");
  print("메시지 데이터: ${message.data}");

  if (message.notification != null) {
    print("알림 제목: ${message.notification?.title}");
    print("알림 내용: ${message.notification?.body}");
  }
}
