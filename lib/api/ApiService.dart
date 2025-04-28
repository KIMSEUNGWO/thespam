
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spam2/component/local_storage.dart';

class ApiService {
  // 싱글톤 패턴 구현
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;
  // final SecureStorage _storage = const SecureStorage();

  // API 기본 URL - 환경에 맞게 수정 필요
  // final String baseUrl = 'https://api.duodate.com/api';
  // final String baseUrl = 'http://10.0.2.2:8080/api/v1';
  final String baseUrl = 'https://others-blvd-constraints-ment.trycloudflare.com/api/v1';

  ApiService._internal() {
    _initDio();
  }

  // Dio 초기화 및 인터셉터 설정
  void _initDio() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    // JWT 토큰 인터셉터
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Authorization'] = await LocalStorage().generateDeviceId();
        return handler.next(options);
      },
      onError: (error, handler) async {
        // if (error.response?.statusCode == 401) {
        //   // 토큰 갱신 시도
        //   if (await _refreshToken()) {
        //     // 토큰 갱신 성공 시 원래 요청 재시도
        //     return handler.resolve(await _retry(error.requestOptions));
        //   }
        // }
        return handler.next(error);
      },
    ));

    // 로깅 인터셉터 (디버그용)
    if (true) { // 개발환경 체크 로직 추가 필요
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // 5. 기기 등록/업데이트
  Future<Response?> deviceLogin() async {
    String? fcmToken = await LocalStorage().generateFcmToken();
    if (fcmToken == null) {
      debugPrint('FCM 토큰 생성 실패!');
      return null;
    }
    try {
      return await dio.post('/login', data: {
        'fcmToken': fcmToken,
      });
    } catch (e) {
      debugPrint('기기 등록 오류: $e');
      rethrow;
    }
  }

  // 6. 연인 관계 관련 API
  // 연결 코드 생성
  Future<Response> generateConnectionCode() async {
    try {
      return await dio.post('/relations/code');
    } catch (e) {
      debugPrint('연결 코드 생성 오류: $e');
      rethrow;
    }
  }

  // 연결 코드로 연인 연결
  Future<Response> connectWithCode(String code) async {
    try {
      return await dio.post('/relations/connect', data: {'code': code});
    } catch (e) {
      debugPrint('연인 연결 오류: $e');
      rethrow;
    }
  }

  // 연인 연결 해제
  Future<Response> disconnectRelation() async {
    try {
      return await dio.delete('/relations');
    } catch (e) {
      debugPrint('연인 연결 해제 오류: $e');
      rethrow;
    }
  }

  // 기기 정보 가져오기
  Future<String> _getDeviceInfo() async {
    // device_info_plus 패키지를 사용하여 구현할 수 있음
    // 여기서는 간단히 구현
    return 'Flutter Device';
  }

  // 7. 인증 관련 API 호출
  // 로그인
  Future<Response> login(String email, String password) async {
    try {
      return await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      debugPrint('로그인 오류: $e');
      rethrow;
    }
  }

  // 회원가입
  Future<Response> register(String email, String password, String displayName) async {
    try {
      return await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });
    } catch (e) {
      debugPrint('회원가입 오류: $e');
      rethrow;
    }
  }

  // 로그아웃
  // Future<Response> logout() async {
  //   try {
  //     final refreshToken = await _storage.readRefreshToken();
  //     return await dio.post('/auth/logout', data: {
  //       'refreshToken': refreshToken,
  //     });
  //   } catch (e) {
  //     debugPrint('로그아웃 오류: $e');
  //     rethrow;
  //   } finally {
  //     // 로컬 토큰 삭제
  //     await _storage.removeAllByToken();
  //   }
  // }
}