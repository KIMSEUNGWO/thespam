
import 'package:spam2/component/formatter/phoneNumber_formatter.dart';

class KrFormatter extends PhoneNumberFormatter {
  const KrFormatter();

  @override
  String format(String text) {
    if (text.isEmpty) return '';
    text = getOnlyNumber(text);
    String formatted = '';

    // 서울 지역번호 (02)로 시작하는 경우
    if (text.startsWith('02')) {
      // 02-XXX-XXXX 또는 02-XXXX-XXXX 형식
      if (text.length <= 2) {
        formatted = text;
      } else if (text.length <= 5) {
        // 02-XXX 형식
        formatted = '${text.substring(0, 2)}-${text.substring(2)}';
      } else if (text.length <= 9) {
        // 02-XXX-XXXX 형식 (7자리 또는 8자리 지역번호)
        final secondPartEndIndex = text.length >= 6 ? 5 : text.length;
        formatted = '${text.substring(0, 2)}-${text.substring(2, secondPartEndIndex)}';

        if (text.length > 5) {
          formatted += '-${text.substring(secondPartEndIndex)}';
        }
      } else {
        // 최대 자릿수 제한 (일반적으로 서울 번호는 02-XXXX-XXXX 형식으로 10자리)
        formatted = '${text.substring(0, 2)}-${text.substring(2, 6)}-${text.substring(6, 10)}';
      }
    }
    else {
      if (text.length <= 3) {
        formatted = text;
      } else if (text.length <= 7) {
        // 010-XXXX 형식
        formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      } else if (text.length <= 11) {
        // 010-XXX-XXXX 또는 010-XXXX-XXXX 형식
        formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';
      } else {
        // 최대 자릿수 제한 (휴대폰 번호는 일반적으로 11자리)
        formatted = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, 11)}';
      }
    }
    return formatted;
  }

}