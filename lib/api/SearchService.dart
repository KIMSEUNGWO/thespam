
import 'package:spam2/api/ApiService.dart';
import 'package:spam2/domain/Phone.dart';
import 'package:spam2/domain/SearchResult.dart';

class SearchService {

  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;

  SearchService._internal();

  Future<SearchResult> search({required String phoneNumber}) async {
    if (phoneNumber.startsWith('02')) {
      return SearchResult(
        phone: Phone(phoneId: 1, phoneNumber: '0212345678', type: PhoneType.UNKNOWN, description: '등록되지 않은 번호'),
        alreadyReported: true,
      );
    } else if (phoneNumber.startsWith('010')) {
      return SearchResult(
        phone: Phone(phoneId: 1, phoneNumber: '01066666666', type: PhoneType.SAFE, description: '신한은행'),
        alreadyReported: false,
      );
    } else {
      return SearchResult(
        phone: Phone(phoneId: 1, phoneNumber: '0212345678', type: PhoneType.SPAM, description: '설문조사'),
        alreadyReported: true,
      );
    }
  }

}