
class Phone {

  final String phoneNumber;
  final PhoneType type;
  final String description;

  Phone({required this.phoneNumber, required this.type, required this.description});
}

enum PhoneType {
  UNKNOWN,
  SAFE,
  SPAM
  ;

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