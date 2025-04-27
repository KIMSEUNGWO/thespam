import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spam2/setting/AndroidDevice.dart';
import 'package:spam2/setting/Device.dart';
import 'package:spam2/setting/IOSDevice.dart';
import 'package:uuid/uuid.dart';

class CallkitComponent {

  static final CallkitComponent _instance = CallkitComponent._internal();
  factory CallkitComponent() => _instance;

  final Uuid _uuid = Uuid();

  CallkitComponent._internal();

  showCallkit(String phoneNumber) async {
    CallKitParams callKitParams = CallKitParams(
        id: _uuid.v4(),
        appName: '통화맑음',
        nameCaller: '이름 어떻게 넣지?',
        handle: phoneNumber,
        type: 0,
        textAccept: '승인',
        textDecline: '거절',
        ios: iOSParam
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
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

}