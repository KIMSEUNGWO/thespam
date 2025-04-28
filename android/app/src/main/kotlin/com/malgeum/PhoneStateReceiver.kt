package com.malgeum

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log

class PhoneStateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.e("PhoneStateReceiver", "!!!!! onReceive 호출됨: ${intent.action} !!!!!")

        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)

            // Android 버전별 전화번호 접근 방식이 다름
            val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            if (phoneNumber.isNullOrEmpty()) return;
            Log.e("PhoneStateReceiver", "!!!!! 전화 상태: $state, 번호: $phoneNumber !!!!!")

            when (state) {
                TelephonyManager.EXTRA_STATE_RINGING -> {
                    Log.e("PhoneStateReceiver", "!!!!! 전화 수신 감지 ${phoneNumber} !!!!!")
                }
                TelephonyManager.EXTRA_STATE_IDLE -> {
                    Log.e("PhoneStateReceiver", "!!!!! 통화 종료 감지 !!!!!")
                    OverlayView.getInstance(context).removeOverlay();
                    CallManager.cancelTimer()
                    MethodChannelHandler.sendCallExit()
                }
                TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                    Log.e("PhoneStateReceiver", "!!!!! 통화 중 감지 !!!!!")
                    CallManager.startTimer(context)
                }
            }
        }
    }
}