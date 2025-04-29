
import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:spam2/component/svg_icon.dart';
part 'Phone.g.dart';
@HiveType(typeId: 1)
class Phone {

  @HiveField(0)
  final int phoneId;
  @HiveField(1)
  final String phoneNumber;
  @HiveField(2)
  final PhoneType type;
  @HiveField(3)
  final String description;

  Phone({required this.phoneId, required this.phoneNumber, required this.type, required this.description});

  Phone.fromDynamic(dynamic data):
    phoneId = data['phoneId'] is int ? data['phoneId'] : int.parse(data['phoneId'].toString()),
    phoneNumber = data['phoneNumber'],
    type = PhoneType.valueOf(data['type']),
    description = data['description'];

  Map<String, dynamic> toMap() {
    return {
      'phoneId': phoneId,
      'phoneNumber': phoneNumber,
      'description': description,
      'type': type.toString(),
    };
  }
}

@HiveType(typeId: 2)
enum PhoneType {

  @HiveField(0)
  UNKNOWN(icon: SIcon.searchNotFound, color: Color(0xFFB7B7B7)),
  @HiveField(1)
  SAFE(icon: SIcon.searchSafe, color: Color(0xFF41BA45)),
  @HiveField(2)
  SPAM(icon: SIcon.searchWarning, color: Color(0xFFE42323))
  ;

  final SIcon icon;
  final Color color;

  const PhoneType({required this.icon, required this.color});


  static PhoneType valueOf(String value) {
    String toUpper = value.toUpperCase();
    if (toUpper == "SAFE") {
      return PhoneType.SAFE;
    } else if (toUpper == "SPAM") {
      return PhoneType.SPAM;
    }
    return PhoneType.UNKNOWN;
  }

}