
import 'dart:convert';

import 'package:spam2/api/ApiService.dart';
import 'package:spam2/domain/SearchResult.dart';

class SearchService {

  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;

  SearchService._internal();

  Future<SearchResult?> search({required String phoneNumber}) async {
    final response = await ApiService().dio.get('/phone',
      queryParameters: {'phone' : phoneNumber}
    );

    if (response.statusCode != 200) {
      return null;
    }
    final json = response.data as Map<String, dynamic>;
    return SearchResult.fromJson(json);
  }

  Future<List<SearchResult>> findAll() async {
    final response = await ApiService().dio.get('/phones');

    if (response.statusCode != 200) {
      return [];
    }
    List<SearchResult> temp = [];

    final json = response.data as List<dynamic>;
    for (var o in json) {
      final a = SearchResult.fromJson(o);
      temp.add(a);
    }
    return temp;
  }

}