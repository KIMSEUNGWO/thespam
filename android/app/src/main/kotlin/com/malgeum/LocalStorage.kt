package com.malgeum

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences

class LocalStorage private constructor(private val context: Context) {

    companion object {
        @SuppressLint("StaticFieldLeak")
        private var INSTANCE: LocalStorage? = null

        fun getInstance(context: Context): LocalStorage {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: LocalStorage(context.applicationContext)
            }
        }
    }

    private fun loadPreferences(): SharedPreferences {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
    }

    fun getDeviceToken(): String? {
        val preferences = loadPreferences()
        return preferences.getString(StorageKey.DEVICE_ID.key, null);
    }
}


enum class StorageKey(var key: String) {

    DEVICE_ID("flutter.UUID")

}