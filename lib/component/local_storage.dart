import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalStorage {

  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  late final SharedPreferences _storage;

  bool _hasKey(LocalStorageKey key) {
    return _storage.containsKey(key.name);
  }

  init() async {
    _storage = await SharedPreferences.getInstance();
  }

  Future<String> generateDeviceId() async {
    LocalStorageKey key = LocalStorageKey.UUID;
    if (_hasKey(key)) {
      return _storage.getString(key.name)!;
    }
    String uuid = const Uuid().v4();
    await _storage.setString(key.name, uuid);
    return uuid;
  }

  Future<String?> generateFcmToken() async {
    LocalStorageKey key = LocalStorageKey.FCM;
    if (_hasKey(key)) {
      return _storage.getString(key.name);
    }
    // 적절한 위치에 선언
    final req = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (req.authorizationStatus == AuthorizationStatus.authorized && fcmToken != null) {
      print('FCM Token: $fcmToken');
      await _storage.setString(key.name, fcmToken);
      return fcmToken;
    } else {
      print('FCM Token: null');
      return null;
    }
  }



}

enum LocalStorageKey {
  UUID,
  FCM,

  BLOCKED_NUMBERS_READ_ONLY, // 차단번호 빠른 감지용
  BLOCKED_NUMBERS_DATA, // 차단번호 자료형
  BLOCKED_NUMBERS_RECORD // 차단기록 목록

  ;

}