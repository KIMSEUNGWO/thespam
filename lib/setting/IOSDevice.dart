
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:spam2/setting/Device.dart';

class IOSDevice extends Device {

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
  Future<bool> checkPermission() {
    // TODO: implement checkPermission
    throw UnimplementedError();
  }

  @override
  Future<bool> startService() {
    // TODO: implement startService
    throw UnimplementedError();
  }

  @override
  Future<bool> isServiceRunning() {
    // TODO: implement isServiceRunning
    throw UnimplementedError();
  }

  @override
  Future<bool> stopService() {
    // TODO: implement stopService
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPermissions() {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }


}