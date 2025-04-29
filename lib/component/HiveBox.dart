
import 'dart:io';

import 'package:hive_flutter/adapters.dart';
import 'package:spam2/component/InitConfig.dart';
import 'package:spam2/component/channel/BlockedNumberHandler.dart';
import 'package:spam2/domain/Phone.dart';
import 'package:spam2/entity/PhoneRecord.dart';
import 'package:spam2/entity/RecordType.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveBox implements InitConfig {

  static final HiveBox _instance = HiveBox._internal();
  factory HiveBox() => _instance;

  final String PHONE_RECORD = 'record';
  final String BLOCKED_NUMBER = 'blocked_number';

  HiveBox._internal();

  @override
  init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(PhoneAdapter());
    Hive.registerAdapter(PhoneTypeAdapter());
    Hive.registerAdapter(PhoneRecordAdapter());
    Hive.registerAdapter(RecordTypeAdapter());

    await Hive.openBox<PhoneRecord>(PHONE_RECORD);
    await Hive.openBox<Phone>(BLOCKED_NUMBER);
  }

  clearHiveData() async {
    // 모든 박스 닫기
    await Hive.close();

    // Hive 디렉토리 가져오기
    final directory = await path_provider.getApplicationDocumentsDirectory();
    final path = directory.path;

    // Hive 파일들 삭제
    Directory(path).listSync().forEach((file) {
      if (file.path.contains('.hive')) {
        file.deleteSync();
      }
    });
  }


  List<PhoneRecord> getRecords() {
    final box = Hive.box<PhoneRecord>(PHONE_RECORD);
    return box.values.toList();
  }

  addRecord(Phone phone, RecordType type, bool isBlocked, int seconds) async {
    PhoneRecord record = PhoneRecord.toRecord(phone, type, isBlocked, seconds);

    final box = Hive.box<PhoneRecord>(PHONE_RECORD);

    // 바로 직전 통화기록과 비교해서 완전히 같으면 카운트 추가
    PhoneRecord? last = box.values.lastOrNull;
    if (last != null && last.phone.phoneNumber == phone.phoneNumber && last.type == type) {
      last.addCount(seconds);
      await box.put(last.recordId, last);
      return;
    }

    int recordId = await box.add(record);
    record.setRecordId(recordId);
    await box.put(recordId, record);
  }

  deleteRecord(PhoneRecord record) async {
    final box = Hive.box<PhoneRecord>(PHONE_RECORD);
    await box.delete(record.recordId);
  }


  List<Phone> getBlockedNumbers() {
    final box = Hive.box<Phone>(BLOCKED_NUMBER);
    return box.values.toList();
  }

  bool isBlockedNumber(String phoneNumber) {
    final box = Hive.box<Phone>(BLOCKED_NUMBER);
    print('비교해봄~');
    for (var o in box.values) {
      print('Box : ${o.phoneNumber} = 비교할 번호 : $phoneNumber');
      if (o.phoneNumber == phoneNumber) {
        return true;
      }
    }
    return false;
  }

  addBlockedNumber(Phone phone) async {
    final box = Hive.box<Phone>(BLOCKED_NUMBER);
    var values = box.values;

    bool isDuplicate = false;
    for (var o in values) {
      if (o.phoneId == phone.phoneId) {
        isDuplicate = true;
        break;
      }
    }
    // 중복이 아닌 경우에만 추가
    if (!isDuplicate) {
      await box.add(phone);
      await BlockedNumberHandler().syncBlockedNumbers();
    }
  }

  deleteBlockedNumber(int phoneId) async {
    final box = Hive.box<Phone>(BLOCKED_NUMBER);

    for (int i = 0; i < box.length; i++) {
      if (box.getAt(i)?.phoneId == phoneId) {
        await box.deleteAt(i);
        await BlockedNumberHandler().syncBlockedNumbers();
        return;
      }
    }
  }


}