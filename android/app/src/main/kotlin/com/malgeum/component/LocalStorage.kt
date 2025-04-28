package com.malgeum.component

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import com.malgeum.Phone
import org.json.JSONArray
import org.json.JSONObject
import androidx.core.content.edit
import com.malgeum.PhoneType

class LocalStorage private constructor(private val context: Context) {

    companion object {
        @SuppressLint("StaticFieldLeak")
        private var INSTANCE: LocalStorage? = null

        fun getInstance(context: Context): LocalStorage {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: LocalStorage(context.applicationContext)
            }
        }
    }

    fun loadBlockedNumbers(): Set<String> {
        val preferences = loadPreferences()

        val blockedNumbersString = preferences.getString(StorageKey.BLOCKED_NUMBERS_READ_ONLY.key, "")

        return if (!blockedNumbersString.isNullOrEmpty()) {
            blockedNumbersString.split(",").map { it.trim() }.toSet()
        } else {
            emptySet()
        }

    }


    private fun loadPreferences(): SharedPreferences {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
    }

    fun appendBlockedNumberRecord(phoneNumber: String) {
        val preferences = loadPreferences()

        val findPhone = findPhoneByNumber(preferences, phoneNumber)

        if (findPhone != null) {
            // 차단 기록 불러오기
            val recordsJson = preferences.getString(StorageKey.BLOCKED_NUMBERS_RECORD.key, "[]")
            val recordsArray = JSONArray(recordsJson)

            // 새 기록 생성
            val newRecord = JSONObject().apply {
                put("phoneId", findPhone.phoneId)
                put("phoneNumber", findPhone.phoneNumber)
                put("timestamp", System.currentTimeMillis())
                put("type", findPhone.type.name)
                put("description", findPhone.description)
            }

            // 기록 추가
            recordsArray.put(newRecord)

            // 변경된 기록 저장
            preferences.edit {
                putString(StorageKey.BLOCKED_NUMBERS_RECORD.key, recordsArray.toString())
            }
        }



    }

    private fun findPhoneByNumber(preferences: SharedPreferences, phoneNumber: String): Phone? {
        val blockedNumbersJson = preferences.getString(StorageKey.BLOCKED_NUMBERS_DATA.key, "[]")
        val jsonArray = JSONArray(blockedNumbersJson)

        // 배열을 처음부터 끝까지 순회하며 phoneNumber가 일치하는지 확인
        for (i in 0 until jsonArray.length()) {
            val item = jsonArray.getJSONObject(i)
            if (item.getString("phoneNumber") == phoneNumber) {
                // 일치하는 항목을 찾으면 바로 Phone 객체로 변환하여 반환
                return Phone(
                    phoneId = item.getLong("phoneId"),
                    phoneNumber = item.getString("phoneNumber"),
                    type = PhoneType.valueOf(item.getString("type")),
                    description = item.getString("description")
                )
            }
        }

        // 일치하는 항목이 없으면 null 반환
        return null
    }
}
enum class StorageKey(var key: String) {

    BLOCKED_NUMBERS_READ_ONLY("flutter.BLOCKED_NUMBERS_READ_ONLY"), // 차단번호 빠른 감지용
    BLOCKED_NUMBERS_DATA("flutter.BLOCKED_NUMBERS_DATA"), // 차단번호 자료형
    BLOCKED_NUMBERS_RECORD("flutter.BLOCKED_NUMBERS_RECORD") // 차단기록 목록
}