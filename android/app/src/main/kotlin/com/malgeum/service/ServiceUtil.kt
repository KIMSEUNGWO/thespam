package com.malgeum.service

import android.app.ActivityManager
import android.content.Context
import com.malgeum.CallDetectionService

class ServiceUtil {

    companion object {

        fun isDetectServiceRunning(context: Context): Boolean {
            return isServiceRunning(context, CallDetectionService::class.java)
        }

        private fun isServiceRunning(context: Context, serviceClass: Class<*>): Boolean {
            val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            return manager.getRunningServices(Integer.MAX_VALUE)
                .any { it.service.className == serviceClass.name }
        }


    }

}