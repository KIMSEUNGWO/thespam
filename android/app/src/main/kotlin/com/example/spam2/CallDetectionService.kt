package com.example.spam2

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat

class CallDetectionService : Service() {
    private val phoneStateReceiver = PhoneStateReceiver()

    override fun onCreate() {
        super.onCreate()
        Log.d("CallDetectionService", "서비스 생성됨")
        startForeground()

        // 전화 상태 변경 이벤트를 감지하기 위한 BroadcastReceiver 등록
        val filter = IntentFilter().apply {
            addAction(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        }
        registerReceiver(phoneStateReceiver, filter)
        Log.d("CallDetectionService", "전화 상태 수신자 등록됨")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("CallDetectionService", "서비스 시작됨")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(phoneStateReceiver)
        } catch (e: Exception) {
            Log.e("CallDetectionService", "수신자 등록 해제 오류: ${e.message}")
        }
        Log.d("CallDetectionService", "서비스 종료됨")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startForeground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "call_detection_service"
            val channel = NotificationChannel(
                channelId,
                "통화 감지 서비스",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "전화 감지를 위한 서비스입니다"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)

            val notification = NotificationCompat.Builder(this, channelId)
                .setContentTitle("통화 감지 서비스")
                .setContentText("전화 감지를 위해 서비스가 실행 중입니다")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()

            startForeground(100, notification)
            Log.d("CallDetectionService", "포그라운드 서비스 시작됨")
        }
    }
}