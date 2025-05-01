
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spam2/component/FontTheme.dart';
import 'package:spam2/setting/Device.dart';

class IOSDevice extends Device {

  // final permissions = [
  //   Permission.phone,
  //   Permission.contacts
  // ];

  @override
  init() async {
    await _listenerEvent();
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

  @override
  Future<bool> checkPermission() async {
    // for (var permission in permissions) {
    //   if (await permission.isDenied) {
    //     return false;
    //   }
    // }
    return await Permission.phone.isGranted;
  }

  @override
  Future<bool> startService() async {
    return true;
  }

  @override
  Future<bool> isServiceRunning() async {
    return true;
  }

  @override
  Future<bool> stopService() async {
    return true;
  }

  @override
  Future<bool> requestPermissions(BuildContext context) async {
    var phoneStatus = await Permission.phone.request();

    // 권한 상태 확인
    if (phoneStatus.isGranted) {
      print('전화 권한이 허용되었습니다.');
    } else {
      print('전화 권한이 거부되었습니다.');
      // 사용자에게 권한 필요성 설명
    }

    // iOS CallKit 설정으로 이동 안내
    openCallKitSettings(context);
    return true;
  }

  void openCallKitSettings(BuildContext context) {
    // iOS에서는 사용자가 직접 설정에서 '전화 차단 및 발신자 확인' 활성화 필요
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('추가 설정 필요'),
        content: Text('전화 차단 기능을 사용하려면 설정 앱에서 "전화 > 전화 차단 및 발신자 확인"에서 앱을 활성화해주세요.',
          style: TextStyle(
            color: FontColor.f2.get(context)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // iOS 설정 앱 열기
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text('설정으로 이동'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('나중에'),
          ),
        ],
      ),
    );
  }


}