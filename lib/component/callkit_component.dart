import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CallkitComponent {

  static final CallkitComponent _instance = CallkitComponent._internal();
  factory CallkitComponent() => _instance;

  final _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = Uuid();

  CallkitComponent._internal();


  init() async {
    if (Platform.isAndroid) {
      await _androidInit();
    } else if (Platform.isIOS) {
      await _iOSInit();
    }
    await _listenerEvent();
  }
  showCallkit(String phoneNumber) async {
    CallKitParams callKitParams = CallKitParams(
        id: _uuid.v4(),
        appName: '통화맑음',
        nameCaller: '이름 어떻게 넣지?',
        handle: phoneNumber,
        type: 0,
        textAccept: '승인',
        textDecline: '거절',

        android: _androidParam,
        ios: iOSParam
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
  _androidInit() async {
    if (await Permission.notification.isGranted) return;
    var androidInfo = await _deviceInfo.androidInfo;
    var sdkVersion = androidInfo.version.sdkInt;

    print('CallkitComponent._androidInit $sdkVersion');
    // Android 13 이상 (SDK 33+)
    if (sdkVersion >= 33) {
      await FlutterCallkitIncoming.requestNotificationPermission({
        "rationaleMessagePermission": "전화 알림을 표시하기 위해 권한이 필요합니다.",
        "postNotificationMessageRequired": "알림 권한이 필요합니다. 설정에서 허용해주세요."
      });
    } else if (sdkVersion >= 34) {
      print('CallkitComponent._androidInit 2');
      // Android 14 이상 (SDK 34+)
      await FlutterCallkitIncoming.requestFullIntentPermission();
    }
  }
  _iOSInit() async {

  }

  Future<void> _listenerEvent() async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
        // 전화 수신 이벤트
          debugPrint('전화 수신');
          break;
        case Event.actionCallAccept:
        // 전화 수락 처리
          debugPrint('전화 수락');
          break;
        case Event.actionCallDecline:
          debugPrint('전화 거절');
          // 전화 거절 처리
          break;
        case Event.actionCallEnded:
        // 통화 종료 처리
          debugPrint('전화 통화 종료');
          break;
        case Event.actionCallTimeout:
        // 타임아웃 처리 (부재중 전화)
          debugPrint('부재중 처리');
          break;
        case Event.actionCallCallback:
        // 부재중 전화 콜백 처리
          debugPrint('부재중 전화 콜백');
          break;
        default:
          print('필요없음~');
      }
    });
  }

  final iOSParam = const IOSParams(
    iconName: '통화맑음',
    handleType: 'generic',
    // 핸들 유형 (generic : 일반식별자, number : 전화번호, email : 이메일 )
    supportsVideo: false,
    // 비디오 통화 지원 안함
    maximumCallGroups: 1,
    // 간단한 설정
    maximumCallsPerCallGroup: 1,
    // 한 번에 하나의 통화만
    audioSessionActive: true,
    // 오디오 세션 활성화
    ringtonePath: 'system_ringtone_default', // 벨소리 경로
  );

  final _androidParam = const AndroidParams(
      isCustomNotification: true,
      // 커스텀 알림 사용 여부
      isShowLogo: false,
      // 로고 표시 여부
      // logoUrl: 'https://i.pravatar.cc/100', // 로고 URL
      ringtonePath: 'system_ringtone_default',
      // 벨소리 경로
      backgroundColor: '#0955fa',
      // 배경색
      // backgroundUrl: 'https://i.pravatar.cc/500', // 배경 이미지 URL
      actionColor: '#4CAF50',
      // 액션 버튼 색상
      textColor: '#ffffff',
      // 텍스트 색상
      incomingCallNotificationChannelName: "Incoming Call",
      // 수신 전화 알림 채널명
      missedCallNotificationChannelName: "Missed Call",
      // 부재중 전화 알림 채널명
      isShowCallID: false // 통화 ID 표시 여부
  );
}