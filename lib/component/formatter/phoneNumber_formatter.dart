
abstract class PhoneNumberFormatter {
  const PhoneNumberFormatter();
  static final RegExp rex = RegExp(r'[^\d]');

  String getOnlyNumber(String text) => text.replaceAll(rex, '');

  String format(String phone);
}