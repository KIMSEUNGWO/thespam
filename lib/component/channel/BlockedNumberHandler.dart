

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:spam2/component/HiveBox.dart';
import 'package:spam2/domain/Phone.dart';
import 'package:spam2/entity/RecordType.dart';

class BlockedNumberHandler {

  static final BlockedNumberHandler _instance = BlockedNumberHandler._internal();
  factory BlockedNumberHandler() => _instance;

  final MethodChannel _channel = const MethodChannel('com.malgeum/blocked_number');

  BlockedNumberHandler._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'loadBlockedNumbers') {
      print('플러터 : loadBlockedNumbers 호출됨 ${HiveBox().getBlockedNumbers()}');
      return HiveBox().getBlockedNumbers().map((phone) => phone.toMap()).toList();
    } else if (call.method == 'appendBlockedNumber') {
      final data = jsonDecode(call.arguments as String);
      Phone phone = Phone.fromDynamic(data);
      HiveBox().addBlockedNumber(phone);
    } else if (call.method == 'deleteBlockedNumber') {
      final data = jsonDecode(call.arguments as String);
      int phoneId = int.parse(data['phoneId'].toString());
      HiveBox().deleteBlockedNumber(phoneId);
    } else if (call.method == 'addBlockedRecord') {
      final data = jsonDecode(call.arguments as String);

      Phone phone = Phone.fromDynamic(data['phone']);
      RecordType recordType = RecordType.valueOf(data['recordType'] as String);
      final isBlocked = data['isBlocked'] as bool;
      final seconds = data['seconds'] as int;

      HiveBox().addRecord(phone, recordType, isBlocked, seconds);

    }
    return null;
  }

  syncBlockedNumbers() async {
    await _channel.invokeMethod('syncBlockedNumbers');
  }
}