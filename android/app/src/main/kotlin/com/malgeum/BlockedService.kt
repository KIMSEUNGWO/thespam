package com.malgeum

import android.annotation.SuppressLint
import android.content.Context
import com.malgeum.component.LocalStorage

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
    private var lastLoadTime: Long = 0
    private val REFRESH_INTERVAL = 15 * 60 * 1000 // 15분

    // 차단 목록 로드
    fun loadBlockedNumbers() {
        blockedNumbersSet = LocalStorage.getInstance(context).loadBlockedNumbers()
        lastLoadTime = System.currentTimeMillis()
    }

    // 번호가 차단되었는지 확인
    fun isBlocked(phoneNumber: String): Boolean {
        // 필요시 리로드
        checkAndReloadIfNeeded()
        return blockedNumbersSet?.contains(phoneNumber) ?: false
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
}