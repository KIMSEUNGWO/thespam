
import 'package:hive/hive.dart';

part 'RecordType.g.dart';
@HiveType(typeId: 4)
enum RecordType {

  @HiveField(0)
  CALL,
  @HiveField(1)
  MISSED_CALL
  ;

  static RecordType valueOf(String value) {
    String toUpper = value.toUpperCase();
    if (toUpper == 'CALL') {
      return RecordType.CALL;
    }
    return RecordType.MISSED_CALL;
  }
}