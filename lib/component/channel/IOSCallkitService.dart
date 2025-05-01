// ios_call_kit_service.dart

import 'dart:io';

import 'package:flutter/services.dart';

class IOSCallKitService {
  static const MethodChannel _channel = MethodChannel('com.malgeum/callkit');

  // 단일 인스턴스 보장
  static final IOSCallKitService _instance = IOSCallKitService._internal();
  factory IOSCallKitService() => _instance;
  IOSCallKitService._internal();

  Future<bool> isCallDirectoryExtensionEnabled() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>('checkExtensionEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking extension status: ${e.message}');
      return false;
    }
  }

  // 차단 번호 저장 (전체 목록 갱신)
  Future<bool> saveBlockingNumbers(List<String> numbers) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveBlockingNumbers', numbers);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error saving blocking numbers: ${e.message}');
      return false;
    }
  }

  // 식별 데이터 저장 (전체 목록 갱신)
  Future<bool> saveIdentificationData(List<Map<String, String>> data) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveIdentificationData', data);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error saving identification data: ${e.message}');
      return false;
    }
  }

  // 차단 번호 추가 (증분 업데이트)
  Future<bool> addBlockingNumbers(List<String> numbers) async {
    try {
      final result = await _channel.invokeMethod<bool>('addBlockingNumbers', numbers);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error adding blocking numbers: ${e.message}');
      return false;
    }
  }

  // 차단 번호 제거 (증분 업데이트)
  Future<bool> removeBlockingNumbers(List<String> numbers) async {
    try {
      final result = await _channel.invokeMethod<bool>('removeBlockingNumbers', numbers);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error removing blocking numbers: ${e.message}');
      return false;
    }
  }

  // 식별 데이터 추가 (증분 업데이트)
  Future<bool> addIdentificationData(List<Map<String, String>> data) async {
    try {
      final result = await _channel.invokeMethod<bool>('addIdentificationData', data);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error adding identification data: ${e.message}');
      return false;
    }
  }

  // 식별 번호 제거 (증분 업데이트)
  Future<bool> removeIdentificationNumbers(List<String> numbers) async {
    try {
      final result = await _channel.invokeMethod<bool>('removeIdentificationNumbers', numbers);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error removing identification numbers: ${e.message}');
      return false;
    }
  }
}