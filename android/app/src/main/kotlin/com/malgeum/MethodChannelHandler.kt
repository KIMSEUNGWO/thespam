package com.malgeum

import android.util.Log
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

object MethodChannelHandler {
    var methodChannel: MethodChannel? = null

    fun sendCallInfo(spamCheckResult: SpamCheckResult) {
        methodChannel?.invokeMethod("onCallDetected", spamCheckResult.toJson())
    }

    fun sendCallExit() {
        methodChannel?.invokeMethod("onCallIdle", null)
    }

    fun sendTimerComplete(spamResult: SpamCheckResult, duration : Int) {
        // Flutter 채널에 타이머 완료 및 스팸 정보 전송
        try {
            methodChannel?.invokeMethod("onTimerComplete", mapOf(
                "phoneNumber" to spamResult.phoneNumber,
                "type" to spamResult.type,
                "duration" to duration
            ))
        } catch (e: Exception) {
            Log.e("MethodChannelHandler", "타이머 완료 신호 전송 실패: ${e.message}")
        }
    }
}