package com.example.spam2

import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.telecom.Connection
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject

@RequiresApi(Build.VERSION_CODES.N)
class CallScreenService : CallScreeningService() {

    companion object {
        // 메서드 채널
        var methodChannel: MethodChannel? = null
    }

    override fun onScreenCall(callDetails: Call.Details) {
        Log.e("CallScreenService", "!!!!! onScreenCall 호출됨 !!!!!")

        // 전화 방향 확인 (수신/발신)
        val callDirection = callDetails.callDirection
        // 수신 전화인지 확인 (Android 11+ 제한 사항 고려)
        val isIncoming = callDirection == Call.Details.DIRECTION_INCOMING
        Log.e("CallScreenService", "!!!!! 통화 방향: $callDirection, 수신 전화 여부: $isIncoming !!!!!")

        // Android 11 이상에서는 수신 전화에 대해서만 번호를 확인할 수 있음
        val phoneNumber = if (isIncoming || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            callDetails.handle?.schemeSpecificPart
        } else {
            null
        }

        if (phoneNumber.isNullOrEmpty()) {
            Log.e("CallScreenService", "!!!!! 전화번호가 null이거나 비어 있음 !!!!!")
            // 번호를 알 수 없더라도 기본 응답 생성
            sendDefaultCall(callDetails)
            return
        }


        // 빠른 응답을 위해 메인 로직을 간소화
        CoroutineScope(Dispatchers.Main).launch {
            Log.e("CallScreenService", "!!!!! 감지된 전화번호: $phoneNumber !!!!!")
            try {
                // 스팸 여부 확인 (캐싱된 결과 또는 간단한 로컬 체크)
                val isSpam = checkSpamNumber(phoneNumber)
                Log.e("CallScreenService", "!!!!! 스팸 여부: $isSpam !!!!!")

                // 응답 생성 - 스팸이면 라벨 표시 및 음소거 적용
                val response = CallResponse.Builder()
                    .setDisallowCall(false)  // 통화 차단 안 함
                    .setRejectCall(false)    // 거절 안 함
                    .setSilenceCall(isSpam)  // 스팸이면 음소거
                    .setSkipCallLog(false)   // 통화 기록 남김
                    .setSkipNotification(false) // 알림 표시
                    .build()

                // 응답 전송
                respondToCall(callDetails, response)

                // Flutter 앱에 전화 정보 전달
                OverlayView.getInstance(this@CallScreenService).showOverlay(
                    phoneNumber = phoneNumber,
                    isSpam = isSpam,
                    type = if (!isSpam) "BANK" else ""
                )
            } catch (e: Exception) {
                Log.e("CallScreenService", "!!!!! 오류 발생: ${e.message} !!!!!")
                // 오류 발생 시 기본 응답
                sendDefaultCall(callDetails)
            }
        }
    }

    private fun sendDefaultCall(callDetails: Call.Details) {
        // 오류 발생 시 기본 응답
        val response = CallResponse.Builder()
            .setDisallowCall(false)
            .setRejectCall(false)
            .setSilenceCall(false)
            .build()

        respondToCall(callDetails, response)
    }

    // 간단한 로컬 스팸 체크 (빠른 응답을 위해)
    private fun checkSpamNumber(phoneNumber: String): Boolean {
        // 간단한 로컬 체크 (예: 특정 숫자로 끝나는 번호)
        val lastFourDigits = phoneNumber.takeLast(4)
        return lastFourDigits == "8635"
    }
}