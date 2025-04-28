
import 'package:spam2/api/ApiService.dart';
import 'package:spam2/domain/SearchResult.dart';

class SearchService {

  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;

  SearchService._internal();

  Future<SearchResult> search({required String phoneNumber}) async {
    if (phoneNumber.startsWith('02')) {
      return SearchResult(
        phone: phoneNumber,
        type: SearchType.NONE,
        alreadyReported: true,
      );
    } else if (phoneNumber.startsWith('010')) {
      return SearchResult(
        phone: phoneNumber,
        type: SearchType.SAFE,
        alreadyReported: false,
      );
    } else {
      return SearchResult(
        phone: phoneNumber,
        type: SearchType.SPAM,
        alreadyReported: true,
      );
    }
  }

}