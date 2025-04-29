package com.malgeum

import android.content.Context
import android.os.CountDownTimer
import android.util.Log

import com.malgeum.model.Phone
import com.malgeum.model.PhoneType

// CallManager.kt - 싱글톤으로 통화 관련 상태 관리
object CallManager {
    private var timer: CountDownTimer? = null
    private var currentSpamResult: Phone? = null
//    private const val TIMER_DURATION = 5 * 60 * 1000L // 5분(밀리초)
    private const val TIMER_DURATION = 10 * 1000L // 10초(밀리초)

    fun setSpamResult(result: Phone) {
        currentSpamResult = result
    }

    fun getSpamResult(): Phone? {
        return currentSpamResult
    }

    fun startTimer(context: Context) {
        // 이미 실행 중인 타이머가 있으면 취소
        cancelTimer()

        Log.d("CallManager", "5분 타이머 시작됨")
        timer = object : CountDownTimer(TIMER_DURATION, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                // 필요한 경우 남은 시간 업데이트
                val secondsRemaining = millisUntilFinished / 1000
                Log.d("CallManager", "타이머 남은 시간: $secondsRemaining 초")
            }

            override fun onFinish() {
                Log.d("CallManager", "타이머 완료 - 후속 작업 실행")
                // 5분 후 실행할 작업
                if (currentSpamResult != null) {
                    performTimerAction(currentSpamResult!!)
                }
                resetState()
            }
        }.start()
    }

    fun cancelTimer() {
        timer?.cancel()
        timer = null
        Log.d("CallManager", "타이머 취소됨")
    }

    fun resetState() {
        cancelTimer()
        currentSpamResult = null
        Log.d("CallManager", "모든 상태 초기화됨")
    }

    private fun performTimerAction(spamResult: Phone) {
        // 타이머 완료 후 실행할 작업
        // 예: 알림 표시, 데이터베이스 업데이트 등
        Log.d("CallManager", "5분 후 실행 - 번호: ${spamResult.phoneNumber}, 유형: ${spamResult.type}")

        // Flutter로 데이터 전송이 필요한 경우
        MethodChannelHandler.sendTimerComplete(spamResult, 5)
    }
}