
import 'package:spam2/component/svg_icon.dart';

class SearchResult {

  final String phone;
  final SearchType type;
  final bool alreadyReported;

  SearchResult({required this.phone, required this.type, required this.alreadyReported});
}

enum SearchType {

  SAFE,
  SPAM,
  NONE
  ;


  getIcon() {
    return switch (this) {
      SearchType.SAFE => SvgIcon.asset(sIcon: SIcon.searchSafe),
      SearchType.SPAM => SvgIcon.asset(sIcon: SIcon.searchWarning),
      SearchType.NONE => SvgIcon.asset(sIcon: SIcon.searchNotFound),
    };
  }
}