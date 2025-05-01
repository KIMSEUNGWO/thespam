// SharedData.swift (새 파일로 생성)
import Foundation

class SharedData {
    static let shared = SharedData()
    private let appGroupID = "group.com.malgeum.spamcall"
    
    // MARK: - 전체 데이터 관리
    
    // 차단 번호 저장
    func saveBlockingNumbers(_ numbers: [String]) {
        let int64Numbers = numbers.compactMap { convertToInt64($0) }
        let userDefaults = UserDefaults(suiteName: appGroupID)
        userDefaults?.set(int64Numbers, forKey: "blockingNumbers")
        userDefaults?.synchronize()
    }
    
    // 식별 데이터 저장
    func saveIdentificationData(_ data: [[String: String]]) {
        NSLog("SharedData: Using App Group ID: \(appGroupID)")
        
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            NSLog("SharedData: ⚠️ Failed to create UserDefaults with App Group ID: \(appGroupID)")
            return
        }
        
        NSLog("SharedData: Saving \(data.count) identification entries")
        for (index, item) in data.enumerated() {
            if index < 5 {
                NSLog("SharedData: Sample entry - phoneNumber: \(item["phoneNumber"] ?? "nil"), description: \(item["description"] ?? "nil")")
            }
        }
        
        userDefaults.set(data, forKey: "identificationData")
        userDefaults.synchronize()
        
        // 즉시 데이터가 저장되었는지 확인
        let savedData = userDefaults.array(forKey: "identificationData") as? [[String: String]] ?? []
        NSLog("SharedData: Verification - Loaded \(savedData.count) entries after saving")
    }
    // MARK: - 증분 업데이트
    
    // 차단 번호 추가 요청
    func addBlockingNumbers(_ numbers: [String]) {
        let int64Numbers = numbers.compactMap { convertToInt64($0) }
        let userDefaults = UserDefaults(suiteName: appGroupID)
        userDefaults?.set(int64Numbers, forKey: "blockingNumbersToAdd")
        userDefaults?.synchronize()
    }
    
    // 차단 번호 제거 요청
    func removeBlockingNumbers(_ numbers: [String]) {
        let int64Numbers = numbers.compactMap { convertToInt64($0) }
        let userDefaults = UserDefaults(suiteName: appGroupID)
        userDefaults?.set(int64Numbers, forKey: "blockingNumbersToRemove")
        userDefaults?.synchronize()
    }
    
    // 식별 데이터 추가 요청
    func addIdentificationData(_ data: [[String: String]]) {
        let userDefaults = UserDefaults(suiteName: appGroupID)
        userDefaults?.set(data, forKey: "identificationDataToAdd")
        userDefaults?.synchronize()
    }
    
    // 식별 번호 제거 요청
    func removeIdentificationNumbers(_ numbers: [String]) {
        let userDefaults = UserDefaults(suiteName: appGroupID)
        userDefaults?.set(numbers, forKey: "identificationNumbersToRemove")
        userDefaults?.synchronize()
    }
    
    // 전화번호 문자열을 Int64로 변환
    private func convertToInt64(_ phoneNumber: String) -> Int64? {
        // 특수 문자 제거
        let digitsOnly = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // 한국 번호 형식 처리: 010XXXXXXXX → 82+10XXXXXXXX
        if digitsOnly.hasPrefix("0") {
            // 첫 번째 0을 제거하고 82 추가
            let numberWithoutFirstZero = digitsOnly.dropFirst()
            let internationalFormat = "82" + numberWithoutFirstZero
            return Int64(internationalFormat)
        }
        
        // 이미 국제 형식이면 그대로 사용
        if digitsOnly.hasPrefix("82") {
            return Int64(digitsOnly)
        }
        
        // 기타 경우 nil 반환
        return nil
    }
    
    // 식별 데이터 로드
    func loadIdentificationData() -> [[String: String]] {
        let userDefaults = UserDefaults(suiteName: appGroupID)
        let data = userDefaults?.array(forKey: "identificationData") as? [[String: String]] ?? []
        NSLog("SharedData: Loaded \(data.count) identification entries")
        return data
    }
    
    // CallDirectoryHandler와 일관된 데이터 로드 함수
    func loadSharedContainerData() -> (blockingNumbers: [Int64], identificationData: [[String: String]]) {
        NSLog("SharedData: Loading data with App Group ID: \(appGroupID)")
        
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            NSLog("SharedData: ⚠️ Failed to create UserDefaults for loading")
            return ([], [])
        }
        
        let blockingNumbers = userDefaults.array(forKey: "blockingNumbers") as? [Int64] ?? []
        let identificationData = userDefaults.array(forKey: "identificationData") as? [[String: String]] ?? []
        
        NSLog("SharedData: Loaded \(blockingNumbers.count) blocking numbers and \(identificationData.count) identification entries")
        
        return (blockingNumbers, identificationData)
    }
}
