import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:spam2/component/callkit_component.dart';

class CallDetectionService {
  static final CallDetectionService _instance = CallDetectionService._internal();
  factory CallDetectionService() => _instance;

  final MethodChannel _channel = const MethodChannel('com.example.spam2/call_detection');

  CallDetectionService._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> initialize() async {
    print("Flutter: 통화 감지 서비스 초기화 시작");
    try {
      await _channel.invokeMethod('initializeCallScreening');
      await _channel.invokeMethod('startCallDetectionService');
      print("Flutter: 통화 감지 서비스 초기화 완료");
    } catch (e) {
      print("Flutter: 통화 감지 서비스 초기화 오류: $e");
    }
  }

  // 서버에 스팸 번호 확인 요청
  Future<bool> checkSpamNumber(String phoneNumber) async {
    try {
      // 여기서 실제 API 호출
      // 간단한 예시로 구현
      return phoneNumber.endsWith('1234'); // 1234로 끝나는 번호는 스팸
    } catch (e) {
      print('스팸 번호 확인 오류: $e');
      return false;
    }
  }

  // 네이티브에서 호출하는 메서드 핸들러
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCallDetected':
        final data = jsonDecode(call.arguments as String);
        _handleCallDetected(
            data['phoneNumber'],
            data['isSpam'],
            data['callDirection']
        );
        break;
      case 'reportLongSpamCall':
        final data = jsonDecode(call.arguments as String);
        _reportLongSpamCall(data['phoneNumber'], data['duration']);
        break;
      default:
        print('알 수 없는 메서드 호출: ${call.method}');
    }
    return null;
  }

  void _handleCallDetected(String phoneNumber, bool isSpam, int callDirection) async {
    print('전화 감지: $phoneNumber, 스팸: $isSpam, 방향: $callDirection');
    if (isSpam) {
      // await CallkitComponent().showCallkit(phoneNumber);
    }
    // UI 업데이트 또는 다른 처리 수행
  }

  void _reportLongSpamCall(String phoneNumber, int duration) {
    print('장시간 스팸 통화 감지: $phoneNumber, 지속시간: ${duration}초');
    // 서버에 스팸 통화 보고
    _sendReportToServer(phoneNumber, duration);
  }

  Future<void> _sendReportToServer(String phoneNumber, int duration) async {
    // 서버 API 호출 구현
    print('서버에 보고: $phoneNumber, $duration초');
  }
  invokeMethod(String method) async {
    await _channel.invokeMethod(method);
  }
}