//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by 김승우 on 5/1/25.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        // 디버깅용 로그 추가
        NSLog("CallDirectoryExtension: beginRequest called")
        
        if context.isIncremental {
            NSLog("CallDirectoryExtension: Performing incremental update")
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
        } else {
            NSLog("CallDirectoryExtension: Performing full update")
            addAllBlockingPhoneNumbers(to: context)
            addAllIdentificationPhoneNumbers(to: context)
        }
        
        context.completeRequest()
    }
    
    private func loadDataFromSharedContainer() -> (blockingNumbers: [Int64], identificationData: [[String: String]]) {
         let appGroupID = "group.com.malgeum.spamcall"
         let userDefaults = UserDefaults(suiteName: appGroupID)
         
         // 차단 번호 목록 로드
         let blockingNumbers = userDefaults?.array(forKey: "blockingNumbers") as? [Int64] ?? []
         
         // 식별 데이터 로드 (번호 + 설명)
         let identificationData = userDefaults?.array(forKey: "identificationData") as? [[String: String]] ?? []
        
         return (blockingNumbers, identificationData)
     }

    // 전체 차단 번호 추가
    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let data = loadDataFromSharedContainer()
        let allPhoneNumbers = data.blockingNumbers
        
        // 번호는 오름차순으로 정렬되어야 함
        for phoneNumber in allPhoneNumbers.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
    }

    // 증분 차단 번호 업데이트
    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // 앱에서 전달받은 추가/제거할 번호 목록 로드
        let appGroupID = "group.com.malgeum.spamcall"
        let userDefaults = UserDefaults(suiteName: appGroupID)
        
        let phoneNumbersToAdd = userDefaults?.array(forKey: "blockingNumbersToAdd") as? [Int64] ?? []
        for phoneNumber in phoneNumbersToAdd.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }

        let phoneNumbersToRemove = userDefaults?.array(forKey: "blockingNumbersToRemove") as? [Int64] ?? []
        for phoneNumber in phoneNumbersToRemove {
            context.removeBlockingEntry(withPhoneNumber: phoneNumber)
        }
        
        // 처리 후 임시 데이터 삭제
        userDefaults?.removeObject(forKey: "blockingNumbersToAdd")
        userDefaults?.removeObject(forKey: "blockingNumbersToRemove")
        userDefaults?.synchronize()
    }
    

    // 전체 발신자 식별 정보 추가
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let data = loadDataFromSharedContainer()
        let identificationData = data.identificationData
        
        NSLog("CallDirectoryExtension: Found \(identificationData.count) identification entries")
        
        // 번호와 설명 추출 및 정렬
        var phoneNumbersWithLabels: [(Int64, String)] = []
        
        for item in identificationData {
            if let phoneNumberStr = item["phoneNumber"],
               let description = item["description"],
               let phoneNumber = self.convertToInt64(phoneNumberStr) {
                phoneNumbersWithLabels.append((phoneNumber, description))
            }
        }
//        phoneNumbersWithLabels.append((827077390179, "광고?"))
        
        NSLog("CallDirectoryExtension: Adding \(phoneNumbersWithLabels.count) hardcoded identification numbers")
        
        for (number, label) in phoneNumbersWithLabels.sorted(by: { $0.0 < $1.0 }) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: label)
            NSLog("CallDirectoryExtension: Added identification for \(number) with label: \(label)")
        }
    }



    // 증분 발신자 식별 정보 업데이트
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let appGroupID = "group.com.malgeum.spamcall"
        let userDefaults = UserDefaults(suiteName: appGroupID)
        
        // 추가할 항목 처리
        let identToAdd = userDefaults?.array(forKey: "identificationDataToAdd") as? [[String: String]] ?? []
        var phoneNumbersToAdd: [(Int64, String)] = []
        
        for item in identToAdd {
            if let phoneNumberStr = item["phoneNumber"],
               let description = item["description"],
               let phoneNumber = self.convertToInt64(phoneNumberStr) {
                phoneNumbersToAdd.append((phoneNumber, description))
            }
        }
        
        // 번호 기준 정렬
        phoneNumbersToAdd.sort { $0.0 < $1.0 }
        
        for (phoneNumber, label) in phoneNumbersToAdd {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }

        // 제거할 항목 처리
        let phoneNumbersToRemove = userDefaults?.array(forKey: "identificationNumbersToRemove") as? [String] ?? []
        for numberStr in phoneNumbersToRemove {
            if let phoneNumber = self.convertToInt64(numberStr) {
                context.removeIdentificationEntry(withPhoneNumber: phoneNumber)
            }
        }
        
        // 처리 후 임시 데이터 삭제
        userDefaults?.removeObject(forKey: "identificationDataToAdd")
        userDefaults?.removeObject(forKey: "identificationNumbersToRemove")
        userDefaults?.synchronize()
    }
    
//    private func convertToInt64(_ phoneNumber: String) -> Int64? {
//        // 전화번호에서 특수문자 제거
//        let digitsOnly = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        
//        // 한국 번호 형식 처리 ("01012345678" -> 821012345678)
//        var processedNumber = digitsOnly
//        if digitsOnly.hasPrefix("0") {
//            processedNumber = "82" + digitsOnly.dropFirst()
//        }
//        
//        return Int64(processedNumber)
//    }
    
    private func convertToInt64(_ phoneNumber: String) -> Int64? {
        // 전화번호에서 특수문자 제거
        let digitsOnly = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // 한국 번호 형식 처리 (국가 코드 추가)
        var processedNumber: String
        
        if digitsOnly.hasPrefix("0") {
            // 01012345678 -> 821012345678
            processedNumber = "82" + digitsOnly.dropFirst()
        } else if digitsOnly.hasPrefix("82") {
            // 이미 국제 형식인 경우
            processedNumber = digitsOnly
        } else {
            // 국가 코드 없는 번호 (10으로 시작하는 경우)
            processedNumber = "82" + digitsOnly
        }
        
        NSLog("Converted phone number: \(phoneNumber) -> \(processedNumber)")
        
        return Int64(processedNumber)
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        print("Call Directory Extension request failed: \(error)")
    }

}
