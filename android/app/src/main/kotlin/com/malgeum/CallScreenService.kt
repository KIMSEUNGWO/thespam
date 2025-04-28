package com.malgeum

import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import androidx.annotation.RequiresApi
import com.malgeum.component.LocalStorage
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@RequiresApi(Build.VERSION_CODES.N)
class CallScreenService : CallScreeningService() {

    companion object {
        // 메서드 채널
        var methodChannel: MethodChannel? = null
    }

    private lateinit var blockedService: BlockedService

    override fun onCreate() {
        super.onCreate()
        blockedService = BlockedService.getInstance(applicationContext)
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

                if (blockedService.isBlocked(phoneNumber)) {
                    Log.e("CallScreenService", "!!!!! 차단된 번호 : $phoneNumber !!!!!")
                    val response = CallResponse.Builder()
                        .setDisallowCall(true)  // 통화 차단
                        .setRejectCall(true)    // 거절
                        .setSkipCallLog(false)   // 통화 기록 남김
                        .setSkipNotification(false) // 알림 표시
                        .build()
                    respondToCall(callDetails, response)
                    LocalStorage.getInstance(applicationContext).appendBlockedNumberRecord(phoneNumber)
                } else {
                    val spamCheckResult = checkSpamNumber(phoneNumber)
                    Log.e("CallScreenService", "!!!!! 스팸 여부: ${spamCheckResult.type} !!!!!")

                    // 응답 생성 - 스팸이면 라벨 표시 및 음소거 적용
                    val response = CallResponse.Builder()
                        .setDisallowCall(false)  // 통화 차단 안 함
                        .setRejectCall(false)    // 거절 안 함
                        .setSkipCallLog(false)   // 통화 기록 남김
                        .setSkipNotification(false) // 알림 표시
                        .build()

                    // 응답 전송
                    respondToCall(callDetails, response)

                    OverlayView.getInstance(this@CallScreenService).showOverlay(
                        phoneNumber = phoneNumber,
                        description = spamCheckResult.description,
                        type = spamCheckResult.type,
                    )
                    // Flutter 앱에 전화 정보 전달
                    if (spamCheckResult.type == PhoneType.SPAM) {
                        CallManager.setSpamResult(spamCheckResult)
                        MethodChannelHandler.sendCallInfo(spamCheckResult)
                    }
                }


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
//            .setSilenceCall(false)
            .build()

        respondToCall(callDetails, response)
    }

    private fun checkSpamNumber(phoneNumber: String): Phone {
        return ApiServer.spamCheck(phoneNumber)
    }
}