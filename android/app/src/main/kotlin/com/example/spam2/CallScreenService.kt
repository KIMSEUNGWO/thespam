package com.example.spam2

import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject

@RequiresApi(Build.VERSION_CODES.N)
class CallScreenService : CallScreeningService() {

    companion object {
        // 스팸 번호 캐시
        private val spamCache = mutableMapOf<String, Boolean>()

        // 통화 시간 추적
        private val callDurations = mutableMapOf<String, Long>()

        // 메서드 채널
        var methodChannel: MethodChannel? = null
    }

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = callDetails.handle?.schemeSpecificPart ?: return

        CoroutineScope(Dispatchers.IO).launch {
            // 스팸 번호인지 확인 (간단 구현)
            val isSpam = checkSpamNumber(phoneNumber)

            // 기본 응답 생성 - 통화 차단하지 않음
            val response = CallResponse.Builder()
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSilenceCall(false)
                .build()

            // 응답 전송
            respondToCall(callDetails, response)

            // Flutter 앱에 전화 정보 전달
            notifyFlutter(phoneNumber, isSpam, callDetails.callDirection)

            // 스팸 번호라면 통화 시간 추적 시작
            if (isSpam) {
                startCallTracking(phoneNumber)
            }
        }
    }

    private fun checkSpamNumber(phoneNumber: String): Boolean {
        // 캐시된 결과가 있으면 사용
        if (spamCache.containsKey(phoneNumber)) {
            return spamCache[phoneNumber] ?: false
        }

        // 테스트용 간단 구현 (1234로 끝나는 번호는 스팸)
        val isSpam = phoneNumber.endsWith("8635")
        spamCache[phoneNumber] = isSpam
        println("isSpam: $isSpam")
        return isSpam
    }

    private fun notifyFlutter(phoneNumber: String, isSpam: Boolean, callDirection: Int) {
        val data = JSONObject().apply {
            put("phoneNumber", phoneNumber)
            put("isSpam", isSpam)
            put("callDirection", callDirection)
        }

        methodChannel?.invokeMethod("onCallDetected", data.toString())
    }

    private fun startCallTracking(phoneNumber: String) {
        callDurations[phoneNumber] = System.currentTimeMillis()

        // 5분 후 통화 시간 확인
        CoroutineScope(Dispatchers.IO).launch {
            Thread.sleep(5 * 60 * 1000) // 5분 대기
            checkCallDuration(phoneNumber)
        }
    }

    private fun checkCallDuration(phoneNumber: String) {
        val startTime = callDurations[phoneNumber] ?: return
        val duration = (System.currentTimeMillis() - startTime) / 1000 // 초 단위로 변환

        // 5분(300초) 이상 통화 중이면 서버에 알림
        if (duration >= 300) {
            val data = JSONObject().apply {
                put("phoneNumber", phoneNumber)
                put("duration", duration)
            }

            methodChannel?.invokeMethod("reportLongSpamCall", data.toString())
        }
    }
}