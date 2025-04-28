import 'dart:convert';
import 'package:flutter/services.dart';

class CallDetectionService {
  static final CallDetectionService _instance = CallDetectionService._internal();
  factory CallDetectionService() => _instance;

  final MethodChannel _channel = const MethodChannel('com.malgeum/call_detection');

  CallDetectionService._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<bool> initialize() async {
    print("Flutter: 통화 감지 서비스 초기화 시작");
    try {
      await _channel.invokeMethod('initializeCallScreening');
      print("Flutter: 통화 감지 서비스 초기화 완료");
      return true;
    } catch (e) {
      print("Flutter: 통화 감지 서비스 초기화 오류: $e");
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermissions');
      return result;
    } catch (e) {
      print('권한 요청 오류: $e');
      return false;
    }
  }

  // 서비스 시작
  Future<bool> startCallDetectionService() async {
    try {
      final bool result = await _channel.invokeMethod('startCallDetectionService');
      return result;
    } catch (e) {
      print('서비스 시작 오류: $e');
      return false;
    }
  }

// 서비스 중지
  Future<bool> stopCallDetectionService() async {
    try {
      final bool result = await _channel.invokeMethod('stopCallDetectionService');
      return result;
    } catch (e) {
      print('서비스 중지 오류: $e');
      return false;
    }
  }

// 서비스 실행 상태 확인
  Future<bool> isCallDetectionServiceRunning() async {
    try {
      final bool result = await _channel.invokeMethod('isCallDetectionServiceRunning');
      return result;
    } catch (e) {
      print('서비스 상태 확인 오류: $e');
      return false;
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
            data['type']
        );
        break;
      case 'onCallIdle':
        print('onCallIdle 호출 성공');
        break;
      default:
        print('알 수 없는 메서드 호출: ${call.method}');
    }
    return null;
  }

  void _handleCallDetected(String phoneNumber, String type) async {
    print('전화 감지: $phoneNumber, 타입: $type');
  }


  invokeMethod(String method) async {
    await _channel.invokeMethod(method);
  }
}