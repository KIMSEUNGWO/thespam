package com.example.spam2

import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

object MethodChannelHandler {
    var methodChannel: MethodChannel? = null

    fun sendCallInfo(phoneNumber: String, isSpam: Boolean, callDirection: Int) {
        val data = JSONObject().apply {
            put("phoneNumber", phoneNumber)
            put("isSpam", isSpam)
            put("callDirection", callDirection)
        }

        methodChannel?.invokeMethod("onCallDetected", data.toString())
    }
}