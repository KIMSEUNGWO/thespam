
import 'package:spam2/component/svg_icon.dart';
import 'package:spam2/domain/Phone.dart';

class SearchResult {

  final Phone phone;
  final bool alreadyReported;

  SearchResult({required this.phone, required this.alreadyReported});

  SearchResult.fromJson(Map<String, dynamic> json):
    phone = Phone.fromDynamic(json),
    alreadyReported = json['alreadyReported'] != null ? json['alreadyReported'] as bool : false;

}
