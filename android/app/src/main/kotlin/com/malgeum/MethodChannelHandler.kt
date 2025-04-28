package com.malgeum

import android.util.Log
import io.flutter.plugin.common.MethodChannel

object MethodChannelHandler {
    var methodChannel: MethodChannel? = null

    fun sendCallInfo(phone: Phone) {
        methodChannel?.invokeMethod("onCallDetected", phone.toJson())
    }

    fun sendCallExit() {
        methodChannel?.invokeMethod("onCallIdle", null)
    }

    fun sendTimerComplete(spamResult: Phone, duration : Int) {
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