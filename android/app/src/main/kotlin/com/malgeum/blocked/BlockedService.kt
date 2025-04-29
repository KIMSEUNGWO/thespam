package com.malgeum.blocked

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import com.malgeum.model.Phone
import com.malgeum.model.RecordType

class BlockedService private constructor(private val context: Context) {

    companion object {
        @SuppressLint("StaticFieldLeak")
        private var INSTANCE: BlockedService? = null

        fun getInstance(context: Context): BlockedService {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: BlockedService(context.applicationContext).also {
                    INSTANCE = it
                    it.loadBlockedNumbers()  // 초기 로드
                }
            }
        }
    }

    private var blockedNumbersSet: Set<String>? = null
    private var blockedPhoneList: List<Phone>? = null
    private var lastLoadTime: Long = 0
    private val REFRESH_INTERVAL = 15 * 60 * 1000 // 15분

    // 차단 목록 로드
    fun loadBlockedNumbers() {
        BlockedRepository.loadBlockedNumbers { blockedList ->
            if (blockedList != null) {
                blockedPhoneList = blockedList
                blockedNumbersSet = blockedList.map { it.phoneNumber }.toSet()
                lastLoadTime = System.currentTimeMillis()
            }
        }
        Log.d("BlockedService", "차단목록 : $blockedNumbersSet");
    }

    // 번호가 차단되었는지 확인
    fun isBlocked(phoneNumber: String): Boolean {
        // 필요시 리로드
//        checkAndReloadIfNeeded()
//        return blockedNumbersSet?.contains(phoneNumber) ?: false
        return blockedNumbersSet?.contains("0212345678") ?: false
    }

    // 필요시 데이터 리로드
    private fun checkAndReloadIfNeeded() {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastLoadTime > REFRESH_INTERVAL || blockedNumbersSet == null) {
            loadBlockedNumbers()
        }
    }

    // 강제로 데이터 리로드 (차단 목록 업데이트 시 호출)
    fun forceReload() {
        loadBlockedNumbers()
    }

    fun addRecord(phoneNumber: String, type : RecordType, isBlocked: Boolean, seconds: Int) {
        if (blockedPhoneList == null) return

        for (phone in blockedPhoneList!!) {
            if (phone.phoneNumber == phoneNumber) {
                BlockedRepository.addRecord(phone, type, isBlocked, seconds)
            }
        }
    }
}