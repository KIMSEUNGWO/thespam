// 사용 예제:
import 'dart:io' show Platform;

import 'package:spam2/component/channel/IOSCallkitService.dart';
import 'package:spam2/domain/SearchResult.dart';

class SpamBlockerManager {
  final IOSCallKitService _iosCallKitService = IOSCallKitService();

  Future<void> initializeCallKit() async {
    if (Platform.isIOS) {
      // Extension이 활성화되어 있는지 확인
      final isEnabled = await _iosCallKitService.isCallDirectoryExtensionEnabled();
      if (isEnabled) {
        // 데이터 로드 및 Extension 갱신
        // TODO
        // await loadAndUpdateSpamData();
      }
    }
  }
  // 서버에서 스팸 번호 목록 로드 후 iOS CallKit에 등록
  Future<void> updateSpamNumbers(List<SearchResult> spamData) async {
    if (Platform.isIOS) {
      try {
        // 차단할 번호 목록
        // final blockingNumbers = spamData
        //     .map((item) => item.phone.phoneNumber)
        //     .toList();

        List<String> blockingNumbers = [];

        // 식별할 번호와 설명
        final identificationData = spamData
            .map((item) => {
              'phoneNumber': item.phone.phoneNumber,
              'description': item.phone.description,
            }).toList();

        // iOS CallKit에 데이터 업데이트
        await _iosCallKitService.saveBlockingNumbers(blockingNumbers);
        await _iosCallKitService.saveIdentificationData(identificationData);

        print('iOS CallKit data updated successfully');
      } catch (e) {
        print('Error updating iOS CallKit data: $e');
      }
    }
  }

  // 개별 스팸 번호 추가
  Future<void> addSpamNumber(String phoneNumber, String description, bool shouldBlock) async {
    if (Platform.isIOS) {
      if (shouldBlock) {
        await _iosCallKitService.addBlockingNumbers([phoneNumber]);
      } else {
        await _iosCallKitService.addIdentificationData([
          {'phoneNumber': phoneNumber, 'description': description}
        ]);
      }
    }
  }

  // 개별 스팸 번호 제거
  Future<void> removeSpamNumber(String phoneNumber, bool wasBlocked) async {
    if (Platform.isIOS) {
      if (wasBlocked) {
        await _iosCallKitService.removeBlockingNumbers([phoneNumber]);
      } else {
        await _iosCallKitService.removeIdentificationNumbers([phoneNumber]);
      }
    }
  }
}