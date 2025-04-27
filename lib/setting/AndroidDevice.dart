
import 'package:flutter/services.dart';
import 'package:spam2/component/CallDetectionService.dart';

import 'Device.dart';

class AndroidDevice extends Device {

  final MethodChannel _channel = const MethodChannel('com.example.spam2/call_detection');

  @override
  init() async {
    // await CallDetectionService().initialize();
  }

  @override
  Future<bool> requestPermissions() async {
    return await CallDetectionService().requestPermissions();
  }

  @override
  Future<bool> startService() async {
    return await CallDetectionService().startCallDetectionService();
  }
  @override
  Future<bool> isServiceRunning() async {
    return await CallDetectionService().isCallDetectionServiceRunning();
  }

  @override
  Future<bool> stopService() async {
    return await CallDetectionService().stopCallDetectionService();
  }

  @override
  Future<bool> checkPermission() async {
    final permissions = await _checkPermissions();
    for (var key in permissions.keys) {
      bool hasPermission = permissions[key]!;
      if (!hasPermission) {
        return false;
      }
    }
    return true;
  }

  Future<Map<String, bool>> _checkPermissions() async {
    try {
      final Map<dynamic, dynamic> permissionResults = await _channel.invokeMethod('permissionCheck');

      // dynamic 키를 String으로 변환
      final Map<String, bool> typedResults = permissionResults.map((key, value) => MapEntry(key.toString(), value as bool));

      print('권한 상태: $typedResults');
      return typedResults;
    } catch (e) {
      print('권한 확인 오류: $e');
      return {
        'READ_PHONE_STATE': false,
        'READ_CALL_LOG': false,
        'ANSWER_PHONE_CALLS': false,
        "ACTION_MANAGE_OVERLAY_PERMISSION" : false
      };
    }
  }


}