
import 'package:hive/hive.dart';
import 'package:spam2/domain/Phone.dart';
import 'package:spam2/entity/RecordType.dart';

part 'PhoneRecord.g.dart';

@HiveType(typeId: 3)
class PhoneRecord {

  @HiveField(0)
  late final int recordId;
  @HiveField(1)
  final Phone phone;
  @HiveField(2)
  final RecordType type;
  @HiveField(3)
  final bool isBlocked;
  @HiveField(4)
  final List<PhoneRecordDetail> detail = [];

  PhoneRecord.toRecord(this.phone, this.type, this.isBlocked, int seconds) {
    addCount(seconds);
  }

  PhoneRecord(this.recordId, this.phone, this.type, this.isBlocked);

  setRecordId(int recordId) {
    this.recordId = recordId;
  }

  addCount(int seconds) {
    detail.add(PhoneRecordDetail(seconds: seconds, time: DateTime.now()));
  }
}

@HiveType(typeId: 5)
class PhoneRecordDetail {

  @HiveField(0)
  final int seconds;
  @HiveField(1)
  final DateTime time;

  PhoneRecordDetail({required this.seconds, required this.time});
}