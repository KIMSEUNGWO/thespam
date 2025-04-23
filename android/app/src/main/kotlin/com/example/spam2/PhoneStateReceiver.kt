package com.example.spam2

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
            val phoneNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10 이상에서는 전화번호 직접 접근이 제한됨
                // 따라서 null일 가능성이 높음
                intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
            } else {
                intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
            }

            Log.e("PhoneStateReceiver", "!!!!! 전화 상태: $state, 번호: $phoneNumber !!!!!")

            when (state) {
                TelephonyManager.EXTRA_STATE_RINGING -> {
                    // 전화 수신 중

                    Log.e("PhoneStateReceiver", "!!!!! 전화 벨 울림 감지 !!!!!")
                    if (!phoneNumber.isNullOrEmpty()) {
                        // Flutter로 전화 정보 전달
                        MethodChannelHandler.sendCallInfo(phoneNumber, false, 1)
                    } else {
                        Log.e("PhoneStateReceiver", "!!!!! 전화번호를 얻을 수 없음 (권한 제한) !!!!!")
                    }
                }
                TelephonyManager.EXTRA_STATE_IDLE -> {
                    Log.e("PhoneStateReceiver", "!!!!! 통화 종료 감지 !!!!!")
                    OverlayView.getInstance(context).removeOverlay();
                }
                TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                    Log.e("PhoneStateReceiver", "!!!!! 통화 중 감지 !!!!!")
                }
            }
        }
    }
}