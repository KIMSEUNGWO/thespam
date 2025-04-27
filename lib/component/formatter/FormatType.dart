
import 'package:spam2/component/formatter/kr_formatter.dart';
import 'package:spam2/component/formatter/phoneNumber_formatter.dart';

enum FormatType {
  KR(KrFormatter());

  final PhoneNumberFormatter _formatter;
  const FormatType(this._formatter);

  format(String text) {
    return _formatter.format(text);
  }
}